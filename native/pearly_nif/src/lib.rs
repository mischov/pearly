#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate rustler;
extern crate scoped_pool;
extern crate syntect;

use rustler::{
    NifEnv,
    NifTerm,
    NifResult,
    NifEncoder,
};
use rustler::env::OwnedEnv;
use rustler::types::binary::NifBinary;

use syntect::easy::HighlightLines;
use syntect::highlighting::{Style, ThemeSet};
use syntect::html::highlighted_snippet_for_string;
use syntect::parsing::SyntaxSet;
use syntect::util::as_24_bit_terminal_escaped;

// Highlight

thread_local!{
    pub static SYNTAX_SET: SyntaxSet = {
        let mut ss: SyntaxSet = syntect::dumps::from_binary(
            // Custom packdump including Elixir syntax
            include_bytes!("../assets/default_nonewlines.packdump"));
        ss.link_syntaxes();
        ss
    }
}

lazy_static!{
    pub static ref THEME_SET: ThemeSet = ThemeSet::load_defaults();
}

pub fn highlight_html(lang: &str, theme: &str, source: &str) -> String {
    let theme = match THEME_SET.themes.get(theme) {
        Some(theme) => theme,
        None => panic!("Unknown theme: `{}`", theme),
    };
    SYNTAX_SET.with(|ss| {
        match ss.find_syntax_by_token(lang) {
            None => String::from(source),
            Some(syntax) => {
                highlighted_snippet_for_string(source, syntax, theme)
            },
        }
    })

}

pub fn highlight_terminal(lang: &str, theme: &str, source: &str) -> String {
    let theme = &THEME_SET.themes[theme];
    SYNTAX_SET.with(|ss| {
        match ss.find_syntax_by_token(lang) {
            None => String::from(source),
            Some(syntax) => {
                let mut result = String::new();
                let mut h = HighlightLines::new(syntax, theme);
                for line in source.lines() {
                    let ranges: Vec<(Style, &str)> = h.highlight(line);
                    let highlighted = as_24_bit_terminal_escaped(&ranges[..], true);
                    if result.is_empty() == true {
                        result.push_str(&highlighted);
                    } else {
                        result.push_str("\n");
                        result.push_str(&highlighted);
                    }
                }
                result
            },
        }
    })
}

pub fn highlight_format(format: &str, lang: &str, theme: &str, source: &str) -> String {
    match format {
        "html" => highlight_html(lang, theme, source),
        "terminal" => highlight_terminal(lang, theme, source),
        _ => panic!("Unknown format: `{}`", format),
    }
}

// NIF

mod atoms {
    rustler_atoms! {
        atom pearly_nif_result;

        atom ok;
        atom error;
        atom nif_panic;
    }
}

lazy_static! {
    static ref POOL: scoped_pool::Pool = scoped_pool::Pool::new(4);
}

fn highlight<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let mut owned_env = OwnedEnv::new();

    let format_term = owned_env.save(args[0]);
    let lang_term = owned_env.save(args[1]);
    let theme_term = owned_env.save(args[2]);
    let source_term = owned_env.save(args[3]);

    let return_pid = env.pid();

    POOL.spawn(move || {
        owned_env.send_and_clear(&return_pid, |inner_env| {
            match std::panic::catch_unwind(|| {
                let format: String = match format_term.load(inner_env).atom_to_string() {
                    Ok(inner) => inner,
                    Err(_) => panic!("argument is not a binary"),
                };
                let lang: NifBinary = match lang_term.load(inner_env).decode() {
                    Ok(inner) => inner,
                    Err(_) => panic!("argument is not a binary"),
                };
                let theme: NifBinary = match theme_term.load(inner_env).decode() {
                    Ok(inner) => inner,
                    Err(_) => panic!("argument is not a binary"),
                };
                let source: NifBinary = match source_term.load(inner_env).decode() {
                    Ok(inner) => inner,
                    Err(_) => panic!("argument is not a binary"),
                };

                let result = highlight_format(
                    &format,
                    std::str::from_utf8(lang.as_slice()).unwrap(),
                    std::str::from_utf8(theme.as_slice()).unwrap(),
                    std::str::from_utf8(source.as_slice()).unwrap(),
                );

                let result_term = result.encode(inner_env);

                (atoms::pearly_nif_result(), atoms::ok(), result_term)
                    .encode(inner_env)
            }) {
                Ok(term) => term,
                Err(err) => {
                    let reason =
                        if let Some(s) = err.downcast_ref::<String>() {
                            s.encode(inner_env)
                        } else if let Some(&s) = err.downcast_ref::<&'static str>() {
                            s.encode(inner_env)
                        } else {
                            atoms::nif_panic().encode(inner_env)
                        };
                    (atoms::pearly_nif_result(), atoms::error(), reason)
                        .encode(inner_env)
                },
            }
        });
    });

    Ok(atoms::ok().encode(env))
}

rustler_export_nifs!(
    "Elixir.Pearly.Native",
    [
        ("highlight", 4, highlight),
    ],
    Some(on_load)
);

fn on_load<'a>(_env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    true
}
