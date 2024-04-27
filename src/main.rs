use std::env;
use std::{fs::File, io::{BufRead, BufReader, Read, Seek}};
use std::process::ExitCode;
use std::collections::HashSet;

#[derive(PartialEq, Eq, Hash, Debug)]
enum Option {
    NumBytes,
    NumLines,
    NumWords,
    NumCharacters,
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let (options, filenames) = parse_args(args);
    let mut status = 0;

    for filename in filenames {
        if let Ok(file) = File::open(&filename) {
            let mut reader = BufReader::new(file);

            print!("  ");
            if options.contains(&Option::NumBytes) {
                print!("{} ", handle_byte_count(&mut reader));
                let _ = reader.rewind();
            }
    
            if options.contains(&Option::NumLines) {
                print!("{} ", handle_line_count(&mut reader));
                let _ = reader.rewind();
            }
    
            if options.contains(&Option::NumWords) {
                print!("{} ", handle_word_count(&mut reader));
                let _ = reader.rewind();
            }
    
            if options.contains(&Option::NumCharacters) {
                print!("{} ", handle_character_count(&mut reader));
                let _ = reader.rewind();
            }
    
            println!("{}", filename)
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
                option_result.insert(Option::NumBytes);
            } else if *arg == String::from("-l") {
                option_result.insert(Option::NumLines);
            } else if *arg == String::from("-w") {
                option_result.insert(Option::NumWords);
            } else if *arg == String::from("-m") {
                option_result.insert(Option::NumCharacters);
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

fn handle_byte_count<R: BufRead>(reader: &mut R) -> usize {
    reader.bytes().count()
}

fn handle_line_count<R: BufRead>(reader: &mut R) -> usize {
    reader.lines().count()
}

fn handle_word_count<R: BufRead>(reader: &mut R) -> usize {
    let mut s = String::new();
    let _ = reader.read_to_string(&mut s);
    s.split_whitespace().count()
}

fn handle_character_count<R: BufRead>(reader: &mut R) -> usize {
    let mut s = String::new();
    let _ = reader.read_to_string(&mut s);
    s.chars().count()
}