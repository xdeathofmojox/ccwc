use std::env;
use std::fs;
use std::process::ExitCode;

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();

    if args.len() < 3 {
        return ExitCode::from(1);
    }

    let option = args[1].as_str();
    let filename = args[2].as_str();
    match option {
        "-c" => {
            if let Ok(metadata) = fs::metadata(filename) {
                println!("  {} {}", metadata.len(), filename);
                ExitCode::from(0)
            } else {
                ExitCode::from(1)
            }
        },
        _ => {
            ExitCode::from(1)
        }
    }
}