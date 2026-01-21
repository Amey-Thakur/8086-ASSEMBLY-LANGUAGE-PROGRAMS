/*
 * 8086 Assembly Emulator - Program Library
 * Created by Amey Thakur
 * https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
 * 
 * All 161 assembly language programs organized by category
 */

const programs = {
    'Addressing Modes': ['comprehensive_8086_addressing_modes_reference.asm'],
    'Arithmetic': ['add_array_of_bytes_from_memory.asm', 'addition_16bit_packed_bcd.asm', 'addition_16bit_simple.asm', 'addition_16bit_with_carry_detection.asm', 'addition_8bit_with_user_input.asm', 'calculate_sum_of_first_n_natural_numbers.asm', 'count_set_bits_in_16bit_binary.asm', 'decimal_adjust_after_addition_demo.asm', 'division_16bit_dividend_by_8bit_divisor.asm', 'generate_multiplication_table_for_number.asm', 'multiplication_8bit_unsigned.asm', 'signed_addition_and_subtraction_demo.asm', 'subtraction_8bit_with_user_input.asm', 'swap_two_numbers_using_registers.asm'],
    'Array Operations': ['calculate_sum_of_array_elements.asm', 'copy_block_of_data_between_arrays.asm', 'count_odd_and_even_numbers_in_array.asm', 'delete_element_from_array_by_index.asm', 'find_maximum_element_in_array.asm', 'find_minimum_element_in_array.asm', 'insert_element_into_array_at_index.asm'],
    'Bitwise Operations': ['bitwise_and_logic_demonstration.asm', 'bitwise_logical_shift_left_and_multiplication.asm', 'bitwise_logical_shift_right_and_division.asm', 'bitwise_not_ones_complement_demonstration.asm', 'bitwise_or_logic_demonstration.asm', 'bitwise_rotate_left_circular_shift.asm', 'bitwise_rotate_right_circular_shift.asm', 'bitwise_xor_logic_demonstration.asm'],
    'Control Flow': ['conditional_branching_and_status_flags.asm', 'for_loop_counter_iteration_pattern.asm', 'if_then_else_conditional_logic_structure.asm', 'loop_instruction_cx_register_control.asm', 'switch_case_multiway_branching_logic.asm', 'unconditional_jump_and_program_redirection.asm', 'while_loop_pre_test_conditional_iteration.asm'],
    'Conversion': ['celsius_fahrenheit_temperature_converter.asm', 'convert_decimal_to_binary_representation.asm', 'convert_decimal_to_octal_representation.asm', 'convert_hexadecimal_to_decimal_string.asm', 'convert_hexadecimal_to_packed_bcd.asm', 'convert_packed_bcd_to_hexadecimal.asm', 'hex_to_seven_segment_decoder_lookup.asm', 'reverse_digits_of_integer_value.asm', 'string_comparison_lexicographical_check.asm', 'string_copy_using_manual_loop_iteration.asm', 'string_copy_using_movsb_instruction.asm'],
    'Data Structures': ['queue.asm', 'stack_array.asm'],
    'Expression': ['average_of_array.asm', 'calculator.asm', 'check_even_odd.asm', 'count_vowels.asm', 'count_words.asm', 'factorial.asm', 'fibonacci.asm', 'gcd_two_numbers.asm', 'power.asm', 'prime_number_check.asm', 'reverse_array.asm', 'string_concatenation.asm', 'substring_search.asm'],
    'External Devices': ['keyboard.asm', 'led_display_test.asm', 'mouse.asm', 'robot.asm', 'stepper_motor.asm', 'thermometer.asm', 'timer.asm', 'traffic_lights.asm', 'traffic_lights_advanced.asm'],
    'File Operations': ['create_file.asm', 'delete_file.asm', 'read_file.asm', 'write_file.asm'],
    'Flags': ['carry_flag.asm', 'overflow_flag.asm', 'parity_flag.asm', 'sign_flag.asm', 'zero_flag.asm'],
    'Graphics': ['colored_text.asm', 'draw_line.asm', 'draw_pixel.asm', 'draw_rectangle.asm'],
    'Input Output': ['display_binary.asm', 'display_decimal.asm', 'display_hex.asm', 'read_number.asm'],
    'Interrupts': ['bios_cursor_position.asm', 'bios_keyboard.asm', 'bios_system_time.asm', 'bios_video_mode.asm', 'dos_display_char.asm', 'dos_display_string.asm', 'dos_read_char.asm', 'dos_read_string.asm'],
    'Introduction': ['data_definition_demo.asm', 'display_characters.asm', 'display_string_direct.asm', 'display_system_time.asm', 'hello_world_dos.asm', 'hello_world_interrupt.asm', 'hello_world_procedure.asm', 'hello_world_procedure_advanced.asm', 'hello_world_string.asm', 'hello_world_vga.asm', 'keyboard_wait_input.asm', 'mov_instruction_demo.asm', 'print_alphabets.asm', 'procedure_demo.asm', 'procedure_multiplication.asm'],
    'Macros': ['conditional_macros.asm', 'macro_with_parameters.asm', 'nested_macros.asm', 'print_string_macro.asm'],
    'Mathematics': ['armstrong_number.asm', 'lcm.asm', 'perfect_number.asm', 'square_root.asm', 'twos_complement.asm'],
    'Matrix': ['matrix_addition.asm', 'matrix_transpose.asm'],
    'Memory Operations': ['block_copy.asm', 'memory_compare.asm', 'memory_fill.asm', 'memory_scan.asm'],
    'Patterns': ['diamond_pattern.asm', 'inverted_triangle.asm', 'number_pyramid.asm', 'triangle_pattern.asm'],
    'Procedures': ['basic_procedure.asm', 'local_variables.asm', 'nested_procedures.asm', 'procedure_parameters.asm', 'recursive_factorial.asm'],
    'Searching': ['binary_search.asm', 'character_occurrences_count.asm', 'linear_search.asm', 'search_element_array.asm'],
    'Simulation': ['fire_monitoring_system.asm', 'garment_defect.asm', 'water_level_controller.asm'],
    'Sorting': ['array_ascending.asm', 'array_descending.asm', 'bubble_sort.asm', 'insertion_sort.asm', 'selection_sort.asm'],
    'Stack Operations': ['push_pop.asm', 'reverse_string_stack.asm', 'swap_using_stack.asm'],
    'String Operations': ['palindrome_check.asm', 'string_length.asm', 'string_reverse.asm', 'to_lowercase.asm', 'to_uppercase.asm'],
    'Utilities': ['beep_sound.asm', 'clear_screen.asm', 'delay_timer.asm', 'display_date.asm', 'password_input.asm']
};
