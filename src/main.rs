use std::env;
use std::fs;
use std::process::ExitCode;
use std::collections::HashSet;

#[derive(PartialEq, Eq, Hash, Debug)]
enum Option {
    NumBytes
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().skip(1).collect();
    let mut success = false;
    let (options, filenames) = parse_args(args);

    if options.contains(&Option::NumBytes) {
        for filename in filenames {
            if let Ok(metadata) = fs::metadata(filename.clone()) {
                println!("  {} {}", metadata.len(), filename);
                success = true;
            } else {
                return ExitCode::from(1);
            }
        }
    }

    ExitCode::from(if success { 0 } else { 1 })
}

fn parse_args(args: Vec<String>) -> (HashSet<Option>, Vec<String>) {
    let mut option_result = HashSet::new();
    let mut file_result: Vec<String> = vec![];

    let mut parsing_options = true;
    for arg in args {
        if parsing_options {
            if *arg == String::from("-c") {
                option_result.insert(Option::NumBytes);
            } else {
                parsing_options = false;
            }
        }

        if !parsing_options {
            file_result.push(String::from(arg));
        }
    }

    (option_result, file_result)
}