#!/usr/bin/env python3
"""Clean zsh history by removing command stanzas that contain 'python heredocs."""

import sys

def parse_zsh_history(filename):
    """Parse zsh history handling multi-line commands with backslash continuations."""
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    
    commands = []
    current_command = []
    
    for line in lines:
        current_command.append(line)
        
        # Check if line ends with backslash (continuation)
        if not line.rstrip().endswith('\\'):
            # Command is complete
            commands.append(current_command)
            current_command = []
    
    # Handle any remaining incomplete command
    if current_command:
        commands.append(current_command)
    
    return commands

def filter_python_commands(commands):
    """Filter out only multi-line command stanzas that contain 'python' (case-insensitive)."""
    filtered = []
    removed_count = 0
    
    for cmd_lines in commands:
        # Only filter if it's a multi-line command (more than 1 line)
        is_multiline = len(cmd_lines) > 1
        
        # Join all lines to check the complete command
        full_command = ''.join(cmd_lines)
        
        # Only remove if it's multi-line AND contains python
        if is_multiline and 'python' in full_command.lower():
            removed_count += 1
        else:
            filtered.extend(cmd_lines)
    
    return filtered, removed_count

def main():
    input_file = "/Users/matthew/.zsh_history"
    output_file = "/Users/matthew/.zsh_history.new"
    backup_file = "/Users/matthew/.zsh_history.backup"
    
    print(f"Parsing {input_file}...")
    commands = parse_zsh_history(input_file)
    print(f"Found {len(commands)} command stanzas")
    
    print("\nFiltering out multi-line commands containing Python...")
    filtered_lines, removed_count = filter_python_commands(commands)
    
    # Create backup
    with open(backup_file, 'w', encoding='utf-8') as f:
        for cmd_lines in commands:
            f.writelines(cmd_lines)
    
    # Write filtered version
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(filtered_lines)
    
    print(f"\nResults:")
    print(f"  Command stanzas removed: {removed_count}")
    print(f"  Command stanzas kept: {len(commands) - removed_count}")
    print(f"\nFiles:")
    print(f"  Backup: {backup_file}")
    print(f"  Filtered: {output_file}")
    print(f"\nTo apply changes, run:")
    print(f"  mv {output_file} {input_file}")

if __name__ == '__main__':
    main()
