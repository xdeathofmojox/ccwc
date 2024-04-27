use std::env;
use std::{fs::{self, File}, io::{BufRead, BufReader, Read}};
use std::process::ExitCode;
use std::collections::HashSet;

#[derive(PartialEq, Eq, Hash, Debug)]
enum Option {
    NumBytes,
    NumLines,
    NumWords,
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let (options, filenames) = parse_args(args);
    let mut status = 0;

    for filename in filenames {
        print!("  ");
        if options.contains(&Option::NumBytes) {
            if let Ok(count) = handle_byte_count(&filename) {
                print!("{} ", count);
            } else {
                status = 1;
            }
        }

        if options.contains(&Option::NumLines) {
            if let Ok(count) = handle_line_count(&filename) {
                print!("{} ", count);
            } else {
                status = 1;
            }
        }

        if options.contains(&Option::NumWords) {
            if let Ok(count) = handle_word_count(&filename) {
                print!("{} ", count);
            } else {
                status = 1;
            }
        }

        println!("{}", filename)
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
                option_result.insert(Option::NumBytes);
            } else if *arg == String::from("-l") {
                option_result.insert(Option::NumLines);
            } else if *arg == String::from("-w") {
                option_result.insert(Option::NumWords);
            }
            else {
                parsing_options = false;
            }
        }

        if !parsing_options {
            file_result.push(String::from(arg));
        }
    }

    (option_result, file_result)
}

fn handle_byte_count(filename: &String) -> Result<u64, String> {
    if let Ok(metadata) = fs::metadata(filename.clone()) {
        return Ok(metadata.len());
    }
    return Err(String::from("Fail"));
}

fn handle_line_count(filename: &String) -> Result<u64, String> {
    if let Ok(file) = File::open(filename) {
        return Ok(BufReader::new(file).lines().count() as u64);
    }
    return Err(String::from("Fail"));
}

fn handle_word_count(filename: &String) -> Result<u64, String> {
    if let Ok(file) = File::open(filename) {
        let mut s = String::new();
        _ = BufReader::new(file).read_to_string(&mut s);
        return Ok(s.split_whitespace().count() as u64);
    }
    return Err(String::from("Fail"));
}