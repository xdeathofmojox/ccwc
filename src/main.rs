mod arguments;
mod counter;
mod flag;
mod runner;

use std::process::ExitCode;

fn main() -> ExitCode {
    let args = std::env::args().skip(1).collect();
    runner::run(args)
}
