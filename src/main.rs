use std::collections::HashSet;
use std::env;
use std::process::{self, ExitCode};
use std::{
    fs::File,
    io::{self, BufRead, BufReader},
};

#[derive(PartialEq, Eq, Hash, Debug)]
enum Option {
    Bytes,
    Lines,
    Words,
    Characters,
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let (options, filenames) = parse_args(args);
    let mut status = 0;

    if filenames.is_empty() {
        let stdin = io::stdin();
        let result = handle_counts(&mut stdin.lock(), &options);
        print_output(&options, result);
        println!();
    }

    for filename in filenames {
        if let Ok(file) = File::open(&filename) {
            let mut reader = BufReader::new(file);
            let result = handle_counts(&mut reader, &options);
            print_output(&options, result);
            println!(" {}", filename);
        } else {
            println!("ccwc: {}: No such file or directory", filename);
            status = 1;
        }
    }

    ExitCode::from(status)
}

fn print_output(
    options: &HashSet<Option>,
    (num_bytes, num_lines, num_words, num_chars): (usize, usize, usize, usize),
) {
    if options.contains(&Option::Lines) {
        print!(" {:>7}", num_lines);
    }

    if options.contains(&Option::Words) {
        print!(" {:>7}", num_words);
    }

    if options.contains(&Option::Bytes) {
        print!(" {:>7}", num_bytes);
    }

    if options.contains(&Option::Characters) {
        print!(" {:>7}", num_chars);
    }
}

fn parse_args(args: Vec<String>) -> (HashSet<Option>, Vec<String>) {
    let mut option_result = HashSet::new();
    let mut file_result: Vec<String> = vec![];

    let mut parsing_options = true;
    for arg in args {
        if parsing_options {
            if let Ok(continue_parsing) = parse_arg(&arg, &mut option_result) {
                parsing_options = continue_parsing;
            } else {
                process::exit(1);
            }
        }

        if !parsing_options {
            file_result.push(arg);
        }
    }

    if option_result.is_empty() {
        option_result.insert(Option::Bytes);
        option_result.insert(Option::Lines);
        option_result.insert(Option::Words);
    }

    (option_result, file_result)
}

fn parse_arg(arg: &str, options: &mut HashSet<Option>) -> Result<bool, String> {
    let mut arg_chars = arg.chars();
    if let Some(starting_arg_char) = arg_chars.next() {
        if starting_arg_char == '-' {
            for arg_char in arg_chars {
                match arg_char {
                    'c' => {
                        options.remove(&Option::Characters);
                        options.insert(Option::Bytes);
                    }
                    'l' => {
                        options.insert(Option::Lines);
                    }
                    'w' => {
                        options.insert(Option::Words);
                    }
                    'm' => {
                        options.remove(&Option::Bytes);
                        options.insert(Option::Characters);
                    }
                    x => {
                        println!("cwwc: illegal option -- {}", x);
                        return Err(String::from("Illegal Option"));
                    }
                }
            }
        } else {
            return Ok(false);
        }
        Ok(true)
    } else {
        Ok(false)
    }
}

fn handle_counts<R: BufRead>(
    reader: &mut R,
    options: &HashSet<Option>,
) -> (usize, usize, usize, usize) {
    let mut s = String::new();
    let mut byte_count: usize = 0;
    let mut line_count: usize = 0;
    let mut word_count: usize = 0;
    let mut char_count: usize = 0;
    while let Ok(size) = reader.read_line(&mut s) {
        if size == 0 {
            break;
        }

        if options.contains(&Option::Bytes) {
            byte_count += size;
        }
        if options.contains(&Option::Lines) {
            line_count += 1;
        }
        if options.contains(&Option::Words) {
            word_count += s.split_whitespace().count();
        }
        if options.contains(&Option::Characters) {
            char_count += s.chars().count();
        }
        s.clear();
    }
    (byte_count, line_count, word_count, char_count)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn counts(input: &str, flags: &str) -> (usize, usize, usize, usize) {
        let (options, _) = parse_args(flags.split_whitespace().map(String::from).collect());
        handle_counts(&mut input.as_bytes(), &options)
    }

    #[test]
    fn default_flags_count_lines_words_bytes() {
        let (bytes, lines, words, _) = counts("hello world\nfoo bar\n", "");
        assert_eq!(lines, 2);
        assert_eq!(words, 4);
        assert_eq!(bytes, 20);
    }

    #[test]
    fn flag_c_counts_bytes() {
        let (bytes, _, _, _) = counts("hello\n", "-c");
        assert_eq!(bytes, 6);
    }

    #[test]
    fn flag_l_counts_lines() {
        let (_, lines, _, _) = counts("a\nb\nc\n", "-l");
        assert_eq!(lines, 3);
    }

    #[test]
    fn flag_w_counts_words() {
        let (_, _, words, _) = counts("one two three\n", "-w");
        assert_eq!(words, 3);
    }

    #[test]
    fn flag_m_counts_chars() {
        let (_, _, _, chars) = counts("héllo\n", "-m");
        assert_eq!(chars, 6); // 5 chars + newline
    }

    #[test]
    fn empty_input() {
        let (bytes, lines, words, _) = counts("", "");
        assert_eq!(bytes, 0);
        assert_eq!(lines, 0);
        assert_eq!(words, 0);
    }
}
