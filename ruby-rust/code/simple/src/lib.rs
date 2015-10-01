extern crate libc;

use std::slice;
use libc::c_int;

#[repr(C)]
pub struct IntArray {
    length: c_int,
    members: *const c_int
}

impl IntArray {
    pub fn first(&self) -> c_int {
        unsafe {
            let slice = slice::from_raw_parts(self.members, self.length as usize);
            *slice.first().unwrap()
        }
    }

    pub fn tail(&self) -> Box<IntArray> {
        unsafe {
            let slice = slice::from_raw_parts(self.members, self.length as usize);
            let (_, tail) = slice.split_at(1 as usize);
            Box::new(IntArray {
                length: tail.len() as c_int,
                members: tail.as_ptr()
            })
        }
    }
}

// passing an integer
#[no_mangle]
pub extern fn add_one(a: c_int) -> c_int {
    a + 1
}

// passing an array of integers
#[no_mangle]
pub extern fn head(a: &IntArray) -> c_int {
    a.first()
}

#[no_mangle]
pub extern fn tail(a: &IntArray) -> Box<IntArray> {
    a.tail()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add_one() {
        assert_eq!(2, add_one(1));
    }

    #[test]
    fn test_head() {
        let ptr = vec!(4, 5, 6).as_ptr();
        let array = IntArray { length: 2, members: ptr };
        assert_eq!(4, head(&array));
    }

    #[test]
    fn test_tail() {
        let array = IntArray { length: 3, members: vec!(7, 8, 9).as_ptr() };
        let expected = IntArray { length: 2, members: vec!(8, 9).as_ptr() };
        let result = *tail(&array);
        assert_eq!(expected.length, result.length);
    }
}

