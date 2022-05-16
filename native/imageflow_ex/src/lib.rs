extern crate imageflow_types;

use rustler::{OwnedBinary, Binary, Encoder, Env, Error, Term};

mod job;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        unknown
    }
}

use job::Job;

macro_rules! job {
    ($id:expr) => {{
        Job::load_from_id($id).ok().unwrap()
    }};
}

#[rustler::nif]
fn get_long_version_string() -> String {
    imageflow_types::version::one_line_version()
}

#[rustler::nif]
pub fn job_create<'a>(env: Env<'a>) -> Result<Term<'a>, Error> {
    match Job::create() {
        Ok(id) => Ok((atoms::ok().to_term(env), id).encode(env)),
        Err(_e) => Err(rustler::Error::Atom("Unable to create context")),
    }
}

#[rustler::nif]
pub fn job_destroy(env: Env, job_id: usize) -> Result<Term, Error> {
    Job::destroy_from_id(job_id).ok().unwrap();

    Ok(atoms::ok().to_term(env))
}

#[rustler::nif]
pub fn job_add_input_buffer<'a>(env: Env<'a>, job_id: usize, io_id: i32, bytes: Binary) -> Result<Term<'a>, Error> {
    match job!(job_id).add_input_buffer(io_id, bytes.as_slice()) {
        Ok(_) => Ok(atoms::ok().encode(env)),
        Err(msg) => Ok((atoms::error(), msg).encode(env)),
    }
}

#[rustler::nif]
pub fn job_add_input_file<'a>(env: Env<'a>, job_id: usize, io_id: i32, path: String) -> Result<Term<'a>, Error> {
    match job!(job_id).add_input_file(io_id, &path) {
        Ok(_) => Ok(atoms::ok().encode(env)),
        Err(msg) => Ok((atoms::error(), msg).encode(env)),
    }
}

#[rustler::nif]
pub fn job_add_output_buffer<'a>(env: Env<'a>, job_id: usize, io_id: i32) -> Result<Term<'a>, Error> {
    match job!(job_id).add_output_buffer(io_id) {
        Ok(_) => Ok(atoms::ok().encode(env)),
        Err(msg) => Ok((atoms::error(), msg).encode(env)),
    }
}

#[rustler::nif]
pub fn job_get_output_buffer<'a>(env: Env<'a>, job_id: usize, io_id: i32) -> Result<Term<'a>, Error> {
    match job!(job_id).get_output_buffer(io_id) {
        Ok(buffer) => {
            let mut erl_bin: OwnedBinary = OwnedBinary::new(buffer.len()).unwrap();
            erl_bin.as_mut_slice().copy_from_slice(&buffer[..]);
            Ok((atoms::ok(), erl_bin.release(env)).encode(env))
        },
        Err(msg) => Ok((atoms::error().to_term(env), msg.to_string()).encode(env)),
    }
}

#[rustler::nif]
pub fn job_save_output_to_file<'a>(env: Env<'a>, job_id: usize, io_id: i32, path: String) -> Result<Term<'a>, Error> {
    match job!(job_id).save_output_to_file(io_id, &path) {
        Ok(_) => Ok(atoms::ok().encode(env)),
        Err(msg) => Ok((atoms::error().to_term(env), msg.to_string()).encode(env)),
    }
}

#[rustler::nif]
pub fn job_message<'a>(env: Env<'a>, job_id: usize, method: String, message: String) -> Result<Term<'a>, Error> {
    match job!(job_id).message(&method, &message) {
        Ok(resp) => Ok((atoms::ok().to_term(env), resp.response_json.encode(env)).encode(env)),
        Err(msg) => Ok((atoms::error().to_term(env), msg).encode(env)),
    }
}

rustler::init!(
    "Elixir.Imageflow.NIF",
    [
        get_long_version_string,
        job_create,
        job_destroy,
        job_add_input_buffer,
        job_add_input_file,
        job_add_output_buffer,
        job_get_output_buffer,
        job_save_output_to_file,
        job_message,
    ]
);