use std::collections::HashSet;

#[derive(PartialEq, Eq, Hash, Debug)]
pub enum Flag {
    Bytes,
    Lines,
    Words,
    Characters,
}

pub fn parse(mut args: Vec<String>) -> Result<(HashSet<Flag>, Vec<String>), String> {
    // Split args at the first non-flag, leaving flag args in `args` and file args in `files`
    let first_file = args
        .iter()
        .position(|a| !a.starts_with('-'))
        .unwrap_or(args.len());
    let files = args.split_off(first_file);

    // Parse all flags
    let mut flags = HashSet::new();
    for arg in &args {
        parse_flag(arg, &mut flags)?;
    }

    // Default flags if none were provided
    if flags.is_empty() {
        flags = [Flag::Bytes, Flag::Lines, Flag::Words].into();
    }

    Ok((flags, files))
}

fn parse_flag(arg: &str, flags: &mut HashSet<Flag>) -> Result<(), String> {
    for c in arg.chars().skip(1) {
        match c {
            'c' => { flags.remove(&Flag::Characters); flags.insert(Flag::Bytes); }
            'l' => { flags.insert(Flag::Lines); }
            'w' => { flags.insert(Flag::Words); }
            'm' => { flags.remove(&Flag::Bytes); flags.insert(Flag::Characters); }
            x => return Err(format!("ccwc: illegal option -- {x}")),
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_args_returns_default_flags() {
        let (flags, files) = parse(vec![]).unwrap();
        assert!(flags.contains(&Flag::Bytes));
        assert!(flags.contains(&Flag::Lines));
        assert!(flags.contains(&Flag::Words));
        assert!(files.is_empty());
    }

    #[test]
    fn explicit_flags_override_defaults() {
        let (flags, _) = parse(vec!["-l".into()]).unwrap();
        assert!(flags.contains(&Flag::Lines));
        assert!(!flags.contains(&Flag::Bytes));
        assert!(!flags.contains(&Flag::Words));
    }

    #[test]
    fn m_flag_replaces_c_flag() {
        let (flags, _) = parse(vec!["-c".into(), "-m".into()]).unwrap();
        assert!(flags.contains(&Flag::Characters));
        assert!(!flags.contains(&Flag::Bytes));
    }

    #[test]
    fn c_flag_replaces_m_flag() {
        let (flags, _) = parse(vec!["-m".into(), "-c".into()]).unwrap();
        assert!(flags.contains(&Flag::Bytes));
        assert!(!flags.contains(&Flag::Characters));
    }

    #[test]
    fn files_collected_after_flags() {
        let (_, files) = parse(vec!["-l".into(), "a.txt".into(), "b.txt".into()]).unwrap();
        assert_eq!(files, vec!["a.txt", "b.txt"]);
    }

    #[test]
    fn illegal_flag_returns_err() {
        assert!(parse(vec!["-z".into()]).is_err());
    }
}
