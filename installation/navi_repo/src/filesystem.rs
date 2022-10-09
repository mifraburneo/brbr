pub use crate::common::fs::{create_dir, exe_string, read_lines, remove_dir, InvalidPath, UnreadableDir};
use crate::env_var;
use crate::parser::Parser;
use crate::prelude::*;

use crate::structures::fetcher;
use directories_next::BaseDirs;
use regex::Regex;

use std::cell::RefCell;
use std::path::MAIN_SEPARATOR;

use walkdir::WalkDir;

pub fn all_cheat_files(path: &Path) -> Vec<String> {
    WalkDir::new(&path)
        .follow_links(true)
        .into_iter()
        .filter_map(|e| e.ok())
        .map(|e| e.path().to_str().unwrap_or("").to_string())
        .filter(|e| e.ends_with(".cheat"))
        .collect::<Vec<String>>()
}

fn paths_from_path_param(env_var: &str) -> impl Iterator<Item = &str> {
    env_var.split(':').filter(|folder| folder != &"")
}

fn compiled_default_path(path: Option<&str>) -> Option<PathBuf> {
    match path {
        Some(path) => {
            let path = if path.contains(MAIN_SEPARATOR) {
                path.split(MAIN_SEPARATOR).next().unwrap()
            } else {
                path
            };
            let path = Path::new(path);
            if path.exists() {
                Some(path.to_path_buf())
            } else {
                None
            }
        }
        None => None,
    }
}

pub fn default_cheat_pathbuf() -> Result<PathBuf> {
    let base_dirs = BaseDirs::new().ok_or_else(|| anyhow!("Unable to get base dirs"))?;
    let mut pathbuf = PathBuf::from(base_dirs.data_dir());
    pathbuf.push("navi");
    pathbuf.push("cheats");
    if !pathbuf.exists() {
        if let Some(path) = compiled_default_path(option_env!("NAVI_PATH")) {
            pathbuf = path;
        }
    }
    Ok(pathbuf)
}

pub fn default_config_pathbuf() -> Result<PathBuf> {
    let base_dirs = BaseDirs::new().ok_or_else(|| anyhow!("Unable to get base dirs"))?;

    let mut pathbuf = PathBuf::from(base_dirs.config_dir());
    pathbuf.push("navi");
    pathbuf.push("config.yaml");
    if !pathbuf.exists() {
        if let Some(path) = compiled_default_path(option_env!("NAVI_CONFIG")) {
            pathbuf = path;
        }
    }
    Ok(pathbuf)
}

pub fn cheat_paths(path: Option<String>) -> Result<String> {
    if let Some(p) = path {
        Ok(p)
    } else {
        Ok(default_cheat_pathbuf()?.to_string())
    }
}

pub fn tmp_pathbuf() -> Result<PathBuf> {
    let mut root = default_cheat_pathbuf()?;
    root.push("tmp");
    Ok(root)
}

fn interpolate_paths(paths: String) -> String {
    let re = Regex::new(r#"\$\{?[a-zA-Z_][a-zA-Z_0-9]*"#).unwrap();
    let mut newtext = paths.to_string();
    for capture in re.captures_iter(&paths) {
        if let Some(c) = capture.get(0) {
            let varname = c.as_str().replace('$', "").replace('{', "").replace('}', "");
            if let Ok(replacement) = &env_var::get(&varname) {
                newtext = newtext
                    .replace(&format!("${}", varname), replacement)
                    .replace(&format!("${{{}}}", varname), replacement);
            }
        }
    }
    newtext
}

pub struct Fetcher {
    path: Option<String>,
    files: RefCell<Vec<String>>,
}

impl Fetcher {
    pub fn new(path: Option<String>) -> Self {
        Self {
            path,
            files: Default::default(),
        }
    }
}

impl fetcher::Fetcher for Fetcher {
    fn fetch(&self, parser: &mut Parser) -> Result<bool> {
        let mut found_something = false;

        let path = self.path.clone();
        let paths = cheat_paths(path);

        if paths.is_err() {
            return Ok(false);
        };

        let paths = paths.expect("Unable to get paths");
        let interpolated_paths = interpolate_paths(paths);
        let folders = paths_from_path_param(&interpolated_paths);

        let home_regex = Regex::new(r"^~").unwrap();
        let home = BaseDirs::new().map(|b| b.home_dir().to_string());

        // parser.filter = self.tag_rules.as_ref().map(|r| gen_lists(r.as_str()));

        for folder in folders {
            let interpolated_folder = match &home {
                Some(h) => home_regex.replace(folder, h).to_string(),
                None => folder.to_string(),
            };
            let folder_pathbuf = PathBuf::from(interpolated_folder);
            for file in all_cheat_files(&folder_pathbuf) {
                self.files.borrow_mut().push(file.clone());
                let index = self.files.borrow().len() - 1;
                let read_file_result = {
                    let path = PathBuf::from(&file);
                    let lines = read_lines(&path)?;
                    parser.read_lines(lines, &file, Some(index))
                };

                if read_file_result.is_ok() && !found_something {
                    found_something = true
                }
            }
        }

        Ok(found_something)
    }

    fn files(&self) -> Vec<String> {
        self.files.borrow().clone()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /* TODO

    use crate::finder::structures::{Opts as FinderOpts, SuggestionType};
    use crate::writer;
    use std::process::{Command, Stdio};

    #[test]
    fn test_read_file() {
        let path = "tests/cheats/ssh.cheat";
        let mut variables = VariableMap::new();
        let mut child = Command::new("cat")
            .stdin(Stdio::piped())
            .stdout(Stdio::null())
            .spawn()
            .unwrap();
        let child_stdin = child.stdin.as_mut().unwrap();
        let mut visited_lines: HashSet<u64> = HashSet::new();
        let mut writer: Box<dyn Writer> = Box::new(writer::terminal::Writer::new());
        read_file(
            path,
            0,
            &mut variables,
            &mut visited_lines,
            &mut *writer,
            child_stdin,
        )
        .unwrap();
        let expected_suggestion = (
            r#" echo -e "$(whoami)\nroot" "#.to_string(),
            Some(FinderOpts {
                header_lines: 0,
                column: None,
                delimiter: None,
                suggestion_type: SuggestionType::SingleSelection,
                ..Default::default()
            }),
        );
        let actual_suggestion = variables.get_suggestion("ssh", "user");
        assert_eq!(Some(&expected_suggestion), actual_suggestion);
    }
    */

    #[test]
    fn splitting_of_dirs_param_may_not_contain_empty_items() {
        // Trailing colon indicates potential extra path. Split returns an empty item for it. This empty item should be filtered away, which is what this test checks.
        let given_path_config = "SOME_PATH:ANOTHER_PATH:";

        let found_paths = paths_from_path_param(given_path_config);

        let mut expected_paths = vec!["SOME_PATH", "ANOTHER_PATH"].into_iter();

        for found in found_paths {
            let expected = expected_paths.next().unwrap();
            assert_eq!(found, expected)
        }
    }

    #[test]
    fn test_default_config_pathbuf() {
        let base_dirs = BaseDirs::new()
            .ok_or_else(|| anyhow!("bad"))
            .expect("could not determine base directories");

        let expected = {
            let mut e = base_dirs.config_dir().to_path_buf();
            e.push("navi");
            e.push("config.yaml");
            e.to_string_lossy().to_string()
        };

        let config = default_config_pathbuf().expect("could not find default config path");

        assert_eq!(expected, config.to_string_lossy().to_string())
    }

    #[test]
    fn test_default_cheat_pathbuf() {
        let base_dirs = BaseDirs::new()
            .ok_or_else(|| anyhow!("bad"))
            .expect("could not determine base directories");

        let expected = {
            let mut e = base_dirs.data_dir().to_path_buf();
            e.push("navi");
            e.push("cheats");
            e.to_string_lossy().to_string()
        };

        let cheats = default_cheat_pathbuf().expect("could not find default config path");

        assert_eq!(expected, cheats.to_string_lossy().to_string())
    }
}
