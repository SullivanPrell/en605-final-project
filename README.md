# EN605 Team 1 Final Project
Authors: Rohan Abraham, Sullivan Prellwitz, Tero Suontaka

This repository contains the source code for an RSA encryption and decryption algorithm in assembly.

In order to run this code, first run make in the top level directory. This will create the executable rsa in the bin folder.

Run this executable and follow the prompts to generate public and private keys, encrypt text, and decrypt text.

Notes:

The maximum number of characters to be read from the console is 255.

All calculations are done in 32 bit signed integers, so modulus sizes larger than 2147483647 will result in errant behavior.

Encryption is done character by character and writes to bin/encrypted.txt.

Decryption reads from the created encrypted.txt file and requires the format of the message to be integers with whitespace between them.

To create the submission archive please run `make submission` NOTE: before doing this please change the archive name to match your JHU ID, please do the same with all the files within the `submission-dir` directory.

The design document and all of its assets are located in `docs/design_doc`and is written in LaTeX.

See the `README.md` file in the `test` directory for notes on the test project
