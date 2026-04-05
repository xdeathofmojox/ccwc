use std::collections::HashSet;
use std::io::BufRead;

use crate::flag::Flag;

pub struct Counts {
    pub bytes: usize,
    pub lines: usize,
    pub words: usize,
    pub chars: usize,
}

pub fn count<R: BufRead>(reader: &mut R, flags: &HashSet<Flag>) -> Counts {
    let mut counts = Counts {
        bytes: 0,
        lines: 0,
        words: 0,
        chars: 0,
    };
    let mut line = String::new();

    while let Ok(n) = reader.read_line(&mut line) {
        if n == 0 {
            break;
        }
        if flags.contains(&Flag::Bytes) {
            counts.bytes += n;
        }
        if flags.contains(&Flag::Lines) {
            counts.lines += 1;
        }
        if flags.contains(&Flag::Words) {
            counts.words += line.split_whitespace().count();
        }
        if flags.contains(&Flag::Characters) {
            counts.chars += line.chars().count();
        }
        line.clear();
    }

    counts
}

pub fn print_counts(flags: &HashSet<Flag>, counts: &Counts) {
    if flags.contains(&Flag::Lines) {
        print!(" {:>7}", counts.lines);
    }
    if flags.contains(&Flag::Words) {
        print!(" {:>7}", counts.words);
    }
    if flags.contains(&Flag::Bytes) {
        print!(" {:>7}", counts.bytes);
    }
    if flags.contains(&Flag::Characters) {
        print!(" {:>7}", counts.chars);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::arguments;

    fn count_str(input: &str, flag_str: &str) -> Counts {
        let args = flag_str.split_whitespace().map(String::from).collect();
        let (flags, _) = arguments::parse_flags_and_filenames(args).unwrap();
        count(&mut input.as_bytes(), &flags)
    }

    #[test]
    fn default_flags_count_lines_words_bytes() {
        let c = count_str("hello world\nfoo bar\n", "");
        assert_eq!(c.lines, 2);
        assert_eq!(c.words, 4);
        assert_eq!(c.bytes, 20);
    }

    #[test]
    fn flag_c_counts_bytes() {
        assert_eq!(count_str("hello\n", "-c").bytes, 6);
    }

    #[test]
    fn flag_l_counts_lines() {
        assert_eq!(count_str("a\nb\nc\n", "-l").lines, 3);
    }

    #[test]
    fn flag_w_counts_words() {
        assert_eq!(count_str("one two three\n", "-w").words, 3);
    }

    #[test]
    fn flag_m_counts_chars() {
        assert_eq!(count_str("héllo\n", "-m").chars, 6); // 5 chars + newline
    }

    #[test]
    fn empty_input() {
        let c = count_str("", "");
        assert_eq!(c.bytes, 0);
        assert_eq!(c.lines, 0);
        assert_eq!(c.words, 0);
    }
}
