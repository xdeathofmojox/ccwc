use std::process::ExitCode;

fn main() -> ExitCode {
    let args = std::env::args().skip(1).collect();
    cc_wc::runner::run(args)
}
