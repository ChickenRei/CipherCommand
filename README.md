### School Project

# Cipher Command

Cipher Command is a command-line tool for encrypting and decrypting text using the Tiny Encryption Algorithm (TEA). Featuring a user-friendly interface for performing encryption and decryption tasks directly from the terminal.

## Download and Run

To use Cipher Command, follow these steps:

1. **Download the Files**:
   - Download the `ccommand.asm` file from  [this site](https://chickenrei.github.io/CipherCommand/).
   - Ensure you have Turbo Assembler (TASM) and Turbo Link (TLink) installed on your system.

2. **Assemble the Code**:
   - Open a terminal or command prompt and navigate to the directory where `ciphercommand.asm` is located.
   - Run the following commands to assemble the code:
     ```sh
     tasm /zi ccommand.asm
     tlink /v ccommand
     ```

3. **Run the Program**:
   - After assembling the code, you should have a `ccommand.exe` file generated.
   - Launch DOSBox or a compatible DOS emulator.
   - Mount the directory containing `ccommand.exe` in DOSBox.
   - Run the program by typing `ccommand` and pressing Enter.
