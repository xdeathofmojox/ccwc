use std::env;
use std::{fs::File, io::{BufRead, BufReader}};
use std::process::ExitCode;
use std::collections::HashSet;

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

    for filename in filenames {
        if let Ok(file) = File::open(&filename) {
            let mut reader = BufReader::new(file);
            let (num_bytes, num_lines, num_words, num_chars) = handle_counts(&mut reader, &options);

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
    
            println!(" {}", filename)
        } else {
            status = 1;
        }
    }

    ExitCode::from(status)
}

fn parse_args(args: Vec<String>) -> (HashSet<Option>, Vec<String>) {
    let mut option_result = HashSet::new();
    let mut file_result: Vec<String> = vec![];

    let mut parsing_options = true;
    for arg in args {
        if parsing_options {
            if *arg == String::from("-c") {
                option_result.remove(&Option::Characters);
                option_result.insert(Option::Bytes);
            } else if *arg == String::from("-l") {
                option_result.insert(Option::Lines);
            } else if *arg == String::from("-w") {
                option_result.insert(Option::Words);
            } else if *arg == String::from("-m") {
                option_result.remove(&Option::Bytes);
                option_result.insert(Option::Characters);
            }
            else {
                parsing_options = false;
            }
        }

        if !parsing_options {
            file_result.push(arg);
        }
    }

    (option_result, file_result)
}

fn handle_counts<R: BufRead>(reader: &mut R, options: &HashSet<Option>) -> (usize, usize, usize, usize) {
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