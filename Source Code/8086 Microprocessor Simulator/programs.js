// -----------------------------------------------------------------------------
// Script Name: programs.js
// Module:      Program Library
// Stack:       JavaScript (ES2020), no dependencies
// Description: The catalogue of every assembly program in this repository,
//              grouped by the folder it lives in.
//
//              GENERATED. Do not edit by hand: run "npm run index" after adding
//              or removing a program, and library.test.mjs will fail the build
//              if this file and the folders ever disagree.
//
//              This is an index, not a copy. The interface fetches the real
//              .asm file from the folder beside this one, so what the simulator
//              runs is what the repository actually holds.
//
//              239 programs across 34 categories.
//
// Authors:     Amey Thakur
// Repository:  https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
// License:     CC BY 4.0
// -----------------------------------------------------------------------------

'use strict';

/** Category name to the files it contains, in the order they appear on disk. */
export const PROGRAMS = {
    'Addressing Modes': ['comprehensive_8086_addressing_modes_reference.asm'],
    'Arithmetic': ['add_array_of_bytes_from_memory.asm', 'addition_16bit_packed_bcd.asm', 'addition_16bit_simple.asm', 'addition_16bit_with_carry_detection.asm', 'addition_8bit_with_user_input.asm', 'calculate_sum_of_first_n_natural_numbers.asm', 'count_set_bits_in_16bit_binary.asm', 'decimal_adjust_after_addition_demo.asm', 'division_16bit_dividend_by_8bit_divisor.asm', 'generate_multiplication_table_for_number.asm', 'multiplication_8bit_unsigned.asm', 'signed_addition_and_subtraction_demo.asm', 'subtraction_8bit_with_user_input.asm', 'swap_two_numbers_using_registers.asm'],
    'Array Operations': ['calculate_sum_of_array_elements.asm', 'copy_block_of_data_between_arrays.asm', 'count_odd_and_even_numbers_in_array.asm', 'delete_element_from_array_by_index.asm', 'find_maximum_element_in_array.asm', 'find_minimum_element_in_array.asm', 'insert_element_into_array_at_index.asm'],
    'Bit Manipulation': ['check_power_of_two.asm', 'count_set_bits_kernighan.asm', 'extract_bit_field.asm', 'isolate_lowest_set_bit.asm', 'reverse_bits_in_word.asm', 'swap_nibbles_in_byte.asm'],
    'Bitwise Operations': ['bitwise_and_logic_demonstration.asm', 'bitwise_logical_shift_left_and_multiplication.asm', 'bitwise_logical_shift_right_and_division.asm', 'bitwise_not_ones_complement_demonstration.asm', 'bitwise_or_logic_demonstration.asm', 'bitwise_rotate_left_circular_shift.asm', 'bitwise_rotate_right_circular_shift.asm', 'bitwise_xor_logic_demonstration.asm'],
    'Conditional Jumps': ['indirect_jump_through_register.asm', 'jcxz_guard_before_a_loop.asm', 'jump_if_equal_or_not_equal.asm', 'jump_on_carry_flag.asm', 'jump_on_overflow_flag.asm', 'jump_on_parity_flag.asm', 'jump_on_sign_flag.asm', 'short_jump_range_and_bridging.asm', 'signed_comparison_family.asm', 'signed_versus_unsigned_trap.asm', 'test_instruction_before_branch.asm', 'unsigned_comparison_family.asm'],
    'Control Flow': ['conditional_branching_and_status_flags.asm', 'for_loop_counter_iteration_pattern.asm', 'if_then_else_conditional_logic_structure.asm', 'loop_instruction_cx_register_control.asm', 'switch_case_multiway_branching_logic.asm', 'unconditional_jump_and_program_redirection.asm', 'while_loop_pre_test_conditional_iteration.asm'],
    'Conversion': ['celsius_fahrenheit_temperature_converter.asm', 'convert_decimal_to_binary_representation.asm', 'convert_decimal_to_octal_representation.asm', 'convert_hexadecimal_to_decimal_string.asm', 'convert_hexadecimal_to_packed_bcd.asm', 'convert_packed_bcd_to_hexadecimal.asm', 'hex_to_seven_segment_decoder_lookup.asm', 'reverse_digits_of_integer_value.asm', 'string_comparison_lexicographical_check.asm', 'string_copy_using_manual_loop_iteration.asm', 'string_copy_using_movsb_instruction.asm'],
    'Data Structures': ['queue.asm', 'stack_array.asm'],
    'Data Transfer': ['in_out_port_transfer.asm', 'lahf_sahf_flag_transfer.asm', 'lds_les_far_pointers.asm', 'lea_versus_offset.asm', 'mov_between_registers.asm', 'mov_immediate_forms.asm', 'mov_memory_and_register.asm', 'mov_segment_registers.asm', 'push_pop_stack_order.asm', 'pushf_popf_preserve_flags.asm', 'xchg_swap_without_temporary.asm', 'xlat_lookup_table.asm'],
    'Expression': ['average_of_array.asm', 'calculator.asm', 'check_even_odd.asm', 'count_vowels.asm', 'count_words.asm', 'factorial.asm', 'fibonacci.asm', 'gcd_two_numbers.asm', 'power.asm', 'prime_number_check.asm', 'reverse_array.asm', 'string_concatenation.asm', 'substring_search.asm'],
    'External Devices': ['keyboard.asm', 'led_display_test.asm', 'mouse.asm', 'robot.asm', 'stepper_motor.asm', 'thermometer.asm', 'timer.asm', 'traffic_lights.asm', 'traffic_lights_advanced.asm'],
    'File Operations': ['create_file.asm', 'delete_file.asm', 'read_file.asm', 'write_file.asm'],
    'Flags': ['carry_flag.asm', 'overflow_flag.asm', 'parity_flag.asm', 'sign_flag.asm', 'zero_flag.asm'],
    'Graphics': ['colored_text.asm', 'draw_line.asm', 'draw_pixel.asm', 'draw_rectangle.asm'],
    'Input Output': ['display_binary.asm', 'display_decimal.asm', 'display_hex.asm', 'read_number.asm'],
    'Interrupts': ['bios_cursor_position.asm', 'bios_keyboard.asm', 'bios_system_time.asm', 'bios_video_mode.asm', 'dos_display_char.asm', 'dos_display_string.asm', 'dos_read_char.asm', 'dos_read_string.asm'],
    'Introduction': ['data_definition_demo.asm', 'display_characters.asm', 'display_string_direct.asm', 'display_system_time.asm', 'hello_world_dos.asm', 'hello_world_interrupt.asm', 'hello_world_procedure.asm', 'hello_world_procedure_advanced.asm', 'hello_world_string.asm', 'hello_world_vga.asm', 'keyboard_wait_input.asm', 'mov_instruction_demo.asm', 'print_alphabets.asm', 'procedure_demo.asm', 'procedure_multiplication.asm'],
    'Loops': ['countdown_versus_countup.asm', 'loop_counted_with_cx.asm', 'loop_over_two_arrays.asm', 'loop_skipping_elements.asm', 'loop_unrolling.asm', 'loop_walking_an_array.asm', 'loop_with_computed_step.asm', 'loop_with_early_exit.asm', 'loope_repeat_while_equal.asm', 'loopne_search_until_found.asm', 'nested_loops_multiplication_table.asm', 'post_test_loop.asm'],
    'Macros': ['conditional_macros.asm', 'macro_with_parameters.asm', 'nested_macros.asm', 'print_string_macro.asm'],
    'Mathematics': ['armstrong_number.asm', 'lcm.asm', 'perfect_number.asm', 'square_root.asm', 'twos_complement.asm'],
    'Matrix': ['matrix_addition.asm', 'matrix_transpose.asm'],
    'Memory Operations': ['block_copy.asm', 'memory_compare.asm', 'memory_fill.asm', 'memory_scan.asm'],
    'Number Theory': ['binomial_coefficient.asm', 'classify_by_divisor_sum.asm', 'collatz_sequence_length.asm', 'coprime_check.asm', 'count_divisors.asm', 'digital_root.asm', 'happy_number_check.asm', 'modular_exponentiation.asm', 'prime_factorisation.asm', 'sieve_of_eratosthenes.asm', 'sum_of_squares_and_cubes.asm', 'triangular_numbers.asm'],
    'Patterns': ['diamond_pattern.asm', 'inverted_triangle.asm', 'number_pyramid.asm', 'triangle_pattern.asm'],
    'Procedures': ['basic_procedure.asm', 'local_variables.asm', 'nested_procedures.asm', 'procedure_parameters.asm', 'recursive_factorial.asm'],
    'Searching': ['binary_search.asm', 'character_occurrences_count.asm', 'linear_search.asm', 'search_element_array.asm'],
    'Shift and Rotate': ['arithmetic_shift_signed_divide.asm', 'multiply_by_ten_using_shifts.asm', 'overflow_flag_on_single_shift.asm', 'pack_two_bytes_into_word.asm', 'rotate_left_no_carry.asm', 'rotate_right_through_carry.asm', 'rotate_through_carry_multiword_shift.asm', 'rotate_to_test_each_bit.asm', 'shift_left_to_multiply.asm', 'shift_right_to_divide_unsigned.asm', 'unpack_word_into_two_bytes.asm', 'variable_shift_count_in_cl.asm'],
    'Signed Arithmetic': ['absolute_value.asm', 'sign_extension_cbw_cwd.asm', 'signed_array_average.asm', 'signed_byte_arithmetic.asm', 'signed_divide_idiv.asm', 'signed_minimum_and_maximum.asm', 'signed_multiply_imul.asm', 'signed_overflow_detection.asm', 'signed_range_check.asm', 'signed_sorting_by_value.asm', 'signed_versus_shift_division.asm', 'two_complement_representation.asm'],
    'Simulation': ['fire_monitoring_system.asm', 'garment_defect.asm', 'water_level_controller.asm'],
    'Sorting': ['array_ascending.asm', 'array_descending.asm', 'bubble_sort.asm', 'insertion_sort.asm', 'selection_sort.asm'],
    'Stack Operations': ['push_pop.asm', 'reverse_string_stack.asm', 'swap_using_stack.asm'],
    'String Operations': ['palindrome_check.asm', 'string_length.asm', 'string_reverse.asm', 'to_lowercase.asm', 'to_uppercase.asm'],
    'Utilities': ['beep_sound.asm', 'clear_screen.asm', 'delay_timer.asm', 'display_date.asm', 'password_input.asm']
};

/** How many programs the library holds. Written out so that anything quoting
 *  the number reads it from here rather than repeating it. */
export const PROGRAM_COUNT = 239;

/** How many categories they are grouped into. */
export const CATEGORY_COUNT = 34;
