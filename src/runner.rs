use std::collections::HashSet;
use std::fs::File;
use std::io::{self, BufReader};
use std::process::ExitCode;

use crate::{counter, flags};

pub fn run(args: Vec<String>) -> ExitCode {
    // Parse flags and filepaths, printing any errors encountered
    let (flags, filepaths) = match flags::parse_flags_and_filenames(args) {
        Ok(result) => result,
        Err(e) => {
            eprintln!("{e}");
            return ExitCode::FAILURE;
        }
    };

    if filepaths.is_empty() {
        process_stdin(&flags)
    } else {
        process_filepaths(flags, filepaths)
    }
}

fn process_stdin(flags: &HashSet<flags::Flag>) -> ExitCode {
    let stdin = io::stdin();
    let counts = counter::count(&mut stdin.lock(), flags);
    counter::print_counts(flags, &counts);
    println!();
    ExitCode::SUCCESS
}

fn process_filepaths(flags: HashSet<flags::Flag>, filepaths: Vec<String>) -> ExitCode {
    let mut status = ExitCode::SUCCESS;

    for filepath in &filepaths {
        process_filepath(filepath, &flags, &mut status);
    }

    status
}

fn process_filepath(filepath: &str, flags: &HashSet<flags::Flag>, status: &mut ExitCode) {
    match File::open(filepath) {
        Ok(file) => {
            let counts = counter::count(&mut BufReader::new(file), flags);
            counter::print_counts(flags, &counts);
            println!(" {filepath}");
        }
        Err(_) => {
            eprintln!("ccwc: {filepath}: No such file or directory");
            *status = ExitCode::FAILURE;
        }
    }
}
