# Use a Rust base image with required dependencies
FROM rust:latest

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    clang \
    llvm \
    libclang-dev \
    libssl-dev

RUN cargo install rusty-blockparser
