### Prerequisites
1. Required software

```bash
# Install NASM assembler
sudo apt update
sudo apt install nasm

# Install DOSBox emulator
sudo apt install dosbox
```

2. Building and Running

    1.  Clone or download the repository
    ```bash
    git clone <https://github.com/LOK-PLOK/Text-Editor.git>

    cd Text-Editor
    ```
    2. Compile the assembly code
    ```bash
    nasm -f bin text-editor-main.asm -o editor.com
    ```
    3. Run in DOSbox
    ```bash
    # Start DOSBox
    dosbox

    # In DOSBox, mount your directory
    mount c <PATH of ASM FILE>/GITHUB/Text-Editor

    # for my case
    mount c /home/lok/GITHUB/Text-Editor
        
    c:
        
    editor.com
    ```

Using the Editor
- Pres ``Enter`` to start editing
- Type text normally
- User ``Arrow Keys`` for navigation
- Press ``F5`` to save (creates output.txt)
- Press ``ESC`` to exit

Troubleshooting
If "command not found": Ensure NASM and DOSBox are installed
If compilation fails: Check file permissions
If file not found: Verify correct directory mounting