onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 31 CPU
add wave -noupdate /cpu_tb/dut/clk
add wave -noupdate /cpu_tb/dut/reset
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_pc
add wave -noupdate /cpu_tb/dut/fetch_instruction
add wave -noupdate /cpu_tb/dut/pipeline_stall
add wave -noupdate /cpu_tb/dut/flush_pipeline
add wave -noupdate -radix unsigned /cpu_tb/dut/correct_pc
add wave -noupdate /cpu_tb/dut/issue_valid
add wave -noupdate -childformat {{/cpu_tb/dut/issue_packet.address -radix unsigned} {/cpu_tb/dut/issue_packet.pc -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/issue_packet.address {-height 15 -radix unsigned} /cpu_tb/dut/issue_packet.pc {-height 15 -radix unsigned}} /cpu_tb/dut/issue_packet
add wave -noupdate /cpu_tb/dut/rs_alu_issue_valid
add wave -noupdate /cpu_tb/dut/rs_mult_issue_valid
add wave -noupdate /cpu_tb/dut/rs_div_issue_valid
add wave -noupdate /cpu_tb/dut/rs_mem_issue_valid
add wave -noupdate /cpu_tb/dut/rs_alu_full
add wave -noupdate /cpu_tb/dut/rs_mult_full
add wave -noupdate /cpu_tb/dut/rs_div_full
add wave -noupdate /cpu_tb/dut/rs_mem_full
add wave -noupdate /cpu_tb/dut/issue_opcode
add wave -noupdate /cpu_tb/dut/issue_dest_reg
add wave -noupdate -radix unsigned /cpu_tb/dut/issue_pc
add wave -noupdate /cpu_tb/dut/issue_is_branch
add wave -noupdate /cpu_tb/dut/rs_alu_execute_valid
add wave -noupdate /cpu_tb/dut/rs_mult_execute_valid
add wave -noupdate /cpu_tb/dut/rs_div_execute_valid
add wave -noupdate /cpu_tb/dut/rs_mem_execute_valid
add wave -noupdate /cpu_tb/dut/rs_alu_packet
add wave -noupdate /cpu_tb/dut/rs_mult_packet
add wave -noupdate /cpu_tb/dut/rs_div_packet
add wave -noupdate /cpu_tb/dut/rs_mem_packet
add wave -noupdate /cpu_tb/dut/rs_alu_tag
add wave -noupdate /cpu_tb/dut/rs_mult_tag
add wave -noupdate /cpu_tb/dut/rs_div_tag
add wave -noupdate /cpu_tb/dut/rs_mem_tag
add wave -noupdate /cpu_tb/dut/alu_result
add wave -noupdate /cpu_tb/dut/mult_result
add wave -noupdate /cpu_tb/dut/div_result
add wave -noupdate /cpu_tb/dut/mem_result
add wave -noupdate /cpu_tb/dut/alu_busy
add wave -noupdate /cpu_tb/dut/mult_busy
add wave -noupdate /cpu_tb/dut/div_busy
add wave -noupdate /cpu_tb/dut/mem_busy
add wave -noupdate /cpu_tb/dut/cdb_packet
add wave -noupdate /cpu_tb/dut/alu_cdb_grant
add wave -noupdate /cpu_tb/dut/mult_cdb_grant
add wave -noupdate /cpu_tb/dut/div_cdb_grant
add wave -noupdate /cpu_tb/dut/mem_cdb_grant
add wave -noupdate /cpu_tb/dut/rob_full
add wave -noupdate /cpu_tb/dut/rob_empty
add wave -noupdate /cpu_tb/dut/rob_tail
add wave -noupdate /cpu_tb/dut/commit_valid
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_dest_reg
add wave -noupdate /cpu_tb/dut/commit_value
add wave -noupdate /cpu_tb/dut/commit_rob_entry
add wave -noupdate /cpu_tb/dut/commit_is_store
add wave -noupdate /cpu_tb/dut/commit_is_branch
add wave -noupdate /cpu_tb/dut/commit_branch_taken
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_branch_target
add wave -noupdate /cpu_tb/dut/branch_mispredict
add wave -noupdate -radix unsigned /cpu_tb/dut/rf_addr1
add wave -noupdate -radix unsigned /cpu_tb/dut/rf_addr2
add wave -noupdate /cpu_tb/dut/rf_data1
add wave -noupdate /cpu_tb/dut/rf_data2
add wave -noupdate /cpu_tb/dut/regfile_wr_en
add wave -noupdate -radix unsigned /cpu_tb/dut/regfile_wr_addr
add wave -noupdate /cpu_tb/dut/regfile_wr_data
add wave -noupdate /cpu_tb/dut/regstat_addr1
add wave -noupdate /cpu_tb/dut/regstat_addr2
add wave -noupdate /cpu_tb/dut/regstat_data1
add wave -noupdate /cpu_tb/dut/regstat_data2
add wave -noupdate /cpu_tb/dut/regstat_wr_en
add wave -noupdate /cpu_tb/dut/regstat_commit_en
add wave -noupdate /cpu_tb/dut/regstat_wr_addr
add wave -noupdate /cpu_tb/dut/regstat_commit_addr
add wave -noupdate /cpu_tb/dut/regstat_rob_addr
add wave -noupdate /cpu_tb/dut/regstat_commit_rob
add wave -noupdate -radix unsigned /cpu_tb/dut/mem_addr
add wave -noupdate /cpu_tb/dut/mem_wdata
add wave -noupdate /cpu_tb/dut/mem_rdata
add wave -noupdate /cpu_tb/dut/mem_wr_en
add wave -noupdate /cpu_tb/dut/take_branch_prediction
add wave -noupdate -radix unsigned /cpu_tb/dut/predicted_target
add wave -noupdate -divider -height 31 FETCH_STAGE
add wave -noupdate /cpu_tb/dut/fetch_stage/clk_i
add wave -noupdate /cpu_tb/dut/fetch_stage/reset_i
add wave -noupdate /cpu_tb/dut/fetch_stage/stall_i
add wave -noupdate /cpu_tb/dut/fetch_stage/flush_i
add wave -noupdate /cpu_tb/dut/fetch_stage/flush_pc_i
add wave -noupdate /cpu_tb/dut/fetch_stage/take_branch_i
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_stage/predicted_pc_i
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_stage/pc_o
add wave -noupdate /cpu_tb/dut/fetch_stage/instruction_o
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_stage/pc_r
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_stage/pc_n
add wave -noupdate -radix unsigned /cpu_tb/dut/fetch_stage/imem/address
add wave -noupdate /cpu_tb/dut/fetch_stage/imem/instruction
add wave -noupdate /cpu_tb/dut/fetch_stage/imem/clk
add wave -noupdate /cpu_tb/dut/fetch_stage/imem/i
add wave -noupdate -divider -height 31 GSHARE_PREDICTOR
add wave -noupdate /cpu_tb/dut/bp/clk_i
add wave -noupdate /cpu_tb/dut/bp/reset_i
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/pc_i
add wave -noupdate /cpu_tb/dut/bp/prediction_o
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/target_o
add wave -noupdate /cpu_tb/dut/bp/update_en_i
add wave -noupdate -radix unsigned -childformat {{{/cpu_tb/dut/bp/update_pc_i[31]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[30]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[29]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[28]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[27]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[26]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[25]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[24]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[23]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[22]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[21]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[20]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[19]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[18]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[17]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[16]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[15]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[14]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[13]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[12]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[11]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[10]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[9]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[8]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[7]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[6]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[5]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[4]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[3]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[2]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[1]} -radix unsigned} {{/cpu_tb/dut/bp/update_pc_i[0]} -radix unsigned}} -subitemconfig {{/cpu_tb/dut/bp/update_pc_i[31]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[30]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[29]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[28]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[27]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[26]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[25]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[24]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[23]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[22]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[21]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[20]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[19]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[18]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[17]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[16]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[15]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[14]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[13]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[12]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[11]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[10]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[9]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[8]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[7]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[6]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[5]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[4]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[3]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[2]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[1]} {-height 15 -radix unsigned} {/cpu_tb/dut/bp/update_pc_i[0]} {-height 15 -radix unsigned}} /cpu_tb/dut/bp/update_pc_i
add wave -noupdate /cpu_tb/dut/bp/actual_taken_i
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/actual_target_i
add wave -noupdate /cpu_tb/dut/bp/ghr
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/pred_pht_addr
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/pred_btb_addr
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/update_pht_addr
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/update_btb_addr
add wave -noupdate /cpu_tb/dut/bp/pht_prediction
add wave -noupdate /cpu_tb/dut/bp/btb_hit
add wave -noupdate -radix unsigned /cpu_tb/dut/bp/btb_target
add wave -noupdate -divider -height 31 DECODE_ISSUE_STAGE
add wave -noupdate /cpu_tb/dut/decode_issue_stage/clk_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/reset_i
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/pc_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/instruction_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/flush_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/stall_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rob_full_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rob_tail_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rob_alloc_valid_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/rob_opcode_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/rob_dest_reg_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/rob_pc_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rob_is_branch_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/rf_addr1_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/rf_addr2_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rf_data1_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rf_data2_i
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/regstat_addr1_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/regstat_addr2_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/regstat_data1_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/regstat_data2_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/regstat_wr_en_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/regstat_wr_addr_o
add wave -noupdate -radix unsigned /cpu_tb/dut/decode_issue_stage/regstat_rob_addr_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_alu_issue_valid_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_mult_issue_valid_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_div_issue_valid_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_mem_issue_valid_o
add wave -noupdate -childformat {{/cpu_tb/dut/decode_issue_stage/issue_packet_o.op -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.vj -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.vk -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.qj -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.qk -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.dest -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.address -radix unsigned} {/cpu_tb/dut/decode_issue_stage/issue_packet_o.pc -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/decode_issue_stage/issue_packet_o.op {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.vj {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.vk {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.qj {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.qk {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.dest {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.address {-height 15 -radix unsigned} /cpu_tb/dut/decode_issue_stage/issue_packet_o.pc {-height 15 -radix unsigned}} /cpu_tb/dut/decode_issue_stage/issue_packet_o
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_alu_full_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_mult_full_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_div_full_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs_mem_full_i
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs1
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rs2
add wave -noupdate /cpu_tb/dut/decode_issue_stage/rd
add wave -noupdate /cpu_tb/dut/decode_issue_stage/immediate
add wave -noupdate /cpu_tb/dut/decode_issue_stage/opcode_decoded
add wave -noupdate /cpu_tb/dut/decode_issue_stage/fu_type_decoded
add wave -noupdate /cpu_tb/dut/decode_issue_stage/is_branch_decoded
add wave -noupdate /cpu_tb/dut/decode_issue_stage/is_store_decoded
add wave -noupdate /cpu_tb/dut/decode_issue_stage/is_load_decoded
add wave -noupdate /cpu_tb/dut/decode_issue_stage/issue_valid
add wave -noupdate /cpu_tb/dut/decode_issue_stage/pipeline_stall
add wave -noupdate -divider -height 31 REGFILE
add wave -noupdate /cpu_tb/dut/regfile_inst/clk
add wave -noupdate /cpu_tb/dut/regfile_inst/reset
add wave -noupdate -radix unsigned /cpu_tb/dut/regfile_inst/rd_addr1
add wave -noupdate -radix unsigned /cpu_tb/dut/regfile_inst/rd_addr2
add wave -noupdate -radix unsigned /cpu_tb/dut/regfile_inst/wr_addr
add wave -noupdate /cpu_tb/dut/regfile_inst/wr_data
add wave -noupdate /cpu_tb/dut/regfile_inst/wr_en
add wave -noupdate /cpu_tb/dut/regfile_inst/rd_data1
add wave -noupdate /cpu_tb/dut/regfile_inst/rd_data2
add wave -noupdate -radix unsigned /cpu_tb/dut/regfile_inst/cycle_count
add wave -noupdate -divider -height 31 REGISTER_STATUS
add wave -noupdate /cpu_tb/dut/regstat_mod/clk_i
add wave -noupdate /cpu_tb/dut/regstat_mod/reset_i
add wave -noupdate /cpu_tb/dut/regstat_mod/issue_wr_en_i
add wave -noupdate /cpu_tb/dut/regstat_mod/commit_wr_en_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/issue_rd_addr1_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/issue_rd_addr2_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/issue_wr_addr_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/commit_wr_addr_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/issue_reorder_addr_i
add wave -noupdate -radix unsigned /cpu_tb/dut/regstat_mod/commit_reorder_addr_i
add wave -noupdate -expand /cpu_tb/dut/regstat_mod/issue_rd_data1_o
add wave -noupdate -expand /cpu_tb/dut/regstat_mod/issue_rd_data2_o
add wave -noupdate -divider -height 31 RESERVATION_STATION_ALU
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/clk_i
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/reset_i
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/flush_i
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/issue_valid_i
add wave -noupdate -childformat {{/cpu_tb/dut/rs_alu_mgr/issue_packet_i.vj -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.vk -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.qj -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.qk -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.dest -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.address -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.pc -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/rs_alu_mgr/issue_packet_i.vj {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.vk {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.qj {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.qk {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.dest {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.address {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/issue_packet_i.pc {-height 15 -radix unsigned}} /cpu_tb/dut/rs_alu_mgr/issue_packet_i
add wave -noupdate -childformat {{/cpu_tb/dut/rs_alu_mgr/cdb_packet_i.branch_target -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/rs_alu_mgr/cdb_packet_i.branch_target {-height 15 -radix unsigned}} /cpu_tb/dut/rs_alu_mgr/cdb_packet_i
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/fu_ready_i
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/execute_valid_o
add wave -noupdate -childformat {{/cpu_tb/dut/rs_alu_mgr/execute_packet_o.vj -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.vk -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.qj -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.qk -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.dest -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.address -radix unsigned} {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.pc -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/rs_alu_mgr/execute_packet_o.vj {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.vk {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.qj {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.qk {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.dest {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.address {-height 15 -radix unsigned} /cpu_tb/dut/rs_alu_mgr/execute_packet_o.pc {-height 15 -radix unsigned}} /cpu_tb/dut/rs_alu_mgr/execute_packet_o
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/execute_tag_o
add wave -noupdate /cpu_tb/dut/rs_alu_mgr/rs_full_o
add wave -noupdate -radix binary /cpu_tb/dut/rs_alu_mgr/rs_empty
add wave -noupdate -radix binary /cpu_tb/dut/rs_alu_mgr/rs_ready
add wave -noupdate -radix unsigned /cpu_tb/dut/rs_alu_mgr/issue_idx
add wave -noupdate -radix unsigned /cpu_tb/dut/rs_alu_mgr/execute_idx
add wave -noupdate -radix unsigned /cpu_tb/dut/rs_alu_mgr/issue_en
add wave -noupdate -radix unsigned /cpu_tb/dut/rs_alu_mgr/execute_en
add wave -noupdate -divider -height 31 RESERVATION_STATION_MULT
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/clk_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/reset_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/flush_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/issue_valid_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/issue_packet_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/cdb_packet_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/fu_ready_i
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/execute_valid_o
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/execute_packet_o
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/execute_tag_o
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/rs_full_o
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/rs_empty
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/rs_ready
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/issue_idx
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/execute_idx
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/issue_en
add wave -noupdate /cpu_tb/dut/rs_mult_mgr/execute_en
add wave -noupdate -divider -height 31 RESERVATION_STATION_DIV
add wave -noupdate /cpu_tb/dut/rs_div_mgr/clk_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/reset_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/flush_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/issue_valid_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/issue_packet_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/cdb_packet_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/fu_ready_i
add wave -noupdate /cpu_tb/dut/rs_div_mgr/execute_valid_o
add wave -noupdate /cpu_tb/dut/rs_div_mgr/execute_packet_o
add wave -noupdate /cpu_tb/dut/rs_div_mgr/execute_tag_o
add wave -noupdate /cpu_tb/dut/rs_div_mgr/rs_full_o
add wave -noupdate /cpu_tb/dut/rs_div_mgr/rs_empty
add wave -noupdate /cpu_tb/dut/rs_div_mgr/rs_ready
add wave -noupdate /cpu_tb/dut/rs_div_mgr/issue_idx
add wave -noupdate /cpu_tb/dut/rs_div_mgr/execute_idx
add wave -noupdate /cpu_tb/dut/rs_div_mgr/issue_en
add wave -noupdate /cpu_tb/dut/rs_div_mgr/execute_en
add wave -noupdate -divider -height 31 RESERVATION_STATION_MEM
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/clk_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/reset_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/flush_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/issue_valid_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/issue_packet_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/cdb_packet_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/fu_ready_i
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/execute_valid_o
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/execute_packet_o
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/execute_tag_o
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/rs_full_o
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/rs_empty
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/rs_ready
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/issue_idx
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/execute_idx
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/issue_en
add wave -noupdate /cpu_tb/dut/rs_mem_mgr/execute_en
add wave -noupdate -divider -height 31 ALU
add wave -noupdate /cpu_tb/dut/alu_unit/clk_i
add wave -noupdate /cpu_tb/dut/alu_unit/reset_i
add wave -noupdate /cpu_tb/dut/alu_unit/execute_valid_i
add wave -noupdate /cpu_tb/dut/alu_unit/execute_packet_i
add wave -noupdate /cpu_tb/dut/alu_unit/rs_tag_i
add wave -noupdate /cpu_tb/dut/alu_unit/cdb_grant_i
add wave -noupdate /cpu_tb/dut/alu_unit/result_o
add wave -noupdate /cpu_tb/dut/alu_unit/busy_o
add wave -noupdate /cpu_tb/dut/alu_unit/alu_operand_a
add wave -noupdate /cpu_tb/dut/alu_unit/alu_operand_b
add wave -noupdate /cpu_tb/dut/alu_unit/alu_result_data
add wave -noupdate /cpu_tb/dut/alu_unit/packet_r
add wave -noupdate /cpu_tb/dut/alu_unit/tag_r
add wave -noupdate /cpu_tb/dut/alu_unit/valid_r
add wave -noupdate -divider -height 31 BOOTH_MULTIPLIER
add wave -noupdate /cpu_tb/dut/mult_unit/clk_i
add wave -noupdate /cpu_tb/dut/mult_unit/reset_i
add wave -noupdate /cpu_tb/dut/mult_unit/execute_valid_i
add wave -noupdate /cpu_tb/dut/mult_unit/execute_packet_i
add wave -noupdate /cpu_tb/dut/mult_unit/rs_tag_i
add wave -noupdate /cpu_tb/dut/mult_unit/cdb_grant_i
add wave -noupdate /cpu_tb/dut/mult_unit/result_o
add wave -noupdate /cpu_tb/dut/mult_unit/busy_o
add wave -noupdate /cpu_tb/dut/mult_unit/mult_v_i
add wave -noupdate /cpu_tb/dut/mult_unit/mult_yumi_i
add wave -noupdate /cpu_tb/dut/mult_unit/mult_ready_o
add wave -noupdate /cpu_tb/dut/mult_unit/mult_v_o
add wave -noupdate /cpu_tb/dut/mult_unit/mult_a_i
add wave -noupdate /cpu_tb/dut/mult_unit/mult_b_i
add wave -noupdate /cpu_tb/dut/mult_unit/mult_data_o
add wave -noupdate /cpu_tb/dut/mult_unit/packet_r
add wave -noupdate /cpu_tb/dut/mult_unit/tag_r
add wave -noupdate /cpu_tb/dut/mult_unit/operation_r
add wave -noupdate /cpu_tb/dut/mult_unit/state_r
add wave -noupdate /cpu_tb/dut/mult_unit/state_n
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/clk_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/reset_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/v_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/yumi_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/a_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/b_i
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/ready_o
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/v_o
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/data_o
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/A_r
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/P_r
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/S_r
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/A_n
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/P_n
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/S_n
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/P_adder_lo
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/P_idle_hold_lo
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/P_lsr_lo
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/step_count_r
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/step_count_n
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/lsb_zeros
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/mult_done
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/ps
add wave -noupdate /cpu_tb/dut/mult_unit/booth_mult_inst/ns
add wave -noupdate -divider -height 31 DIVISION
add wave -noupdate /cpu_tb/dut/div_unit/clk_i
add wave -noupdate /cpu_tb/dut/div_unit/reset_i
add wave -noupdate /cpu_tb/dut/div_unit/execute_valid_i
add wave -noupdate /cpu_tb/dut/div_unit/execute_packet_i
add wave -noupdate /cpu_tb/dut/div_unit/rs_tag_i
add wave -noupdate /cpu_tb/dut/div_unit/cdb_grant_i
add wave -noupdate /cpu_tb/dut/div_unit/result_o
add wave -noupdate /cpu_tb/dut/div_unit/busy_o
add wave -noupdate /cpu_tb/dut/div_unit/div_v_i
add wave -noupdate /cpu_tb/dut/div_unit/div_yumi_i
add wave -noupdate /cpu_tb/dut/div_unit/div_ready_o
add wave -noupdate /cpu_tb/dut/div_unit/div_v_o
add wave -noupdate /cpu_tb/dut/div_unit/div_signed_i
add wave -noupdate /cpu_tb/dut/div_unit/div_a_i
add wave -noupdate /cpu_tb/dut/div_unit/div_b_i
add wave -noupdate /cpu_tb/dut/div_unit/div_div_o
add wave -noupdate /cpu_tb/dut/div_unit/div_rem_o
add wave -noupdate /cpu_tb/dut/div_unit/packet_r
add wave -noupdate /cpu_tb/dut/div_unit/tag_r
add wave -noupdate /cpu_tb/dut/div_unit/operation_r
add wave -noupdate /cpu_tb/dut/div_unit/state_r
add wave -noupdate /cpu_tb/dut/div_unit/state_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/clk_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/reset_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/signed_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/v_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/yumi_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/a_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/b_i
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/ready_o
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/v_o
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/div_o
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/rem_o
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/ps
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/ns
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/count_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/count_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/AQ_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/AQ_shifted
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/AQ_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/M_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_shifted_lo
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_shifted_lo
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/b_input
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/a_input
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_comp_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_correct_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_n
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_adder_lo
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_adder_li1
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_adder_li2
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_out
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_out
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_inv_li
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/Q_inv_li
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/count_eq_zero
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_shifted_ge_zero
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_n_ge_zero
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/A_r_ge_zero
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/retain_A_val
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/retain_Q_val
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/a_lt_b
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/a_lt_b_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/negate_quot_out_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/negate_rem_out_r
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/a_neg
add wave -noupdate /cpu_tb/dut/div_unit/nrd_div_inst/b_neg
add wave -noupdate -divider -height 31 DATA_MEMORY
add wave -noupdate /cpu_tb/dut/mem_unit/clk_i
add wave -noupdate /cpu_tb/dut/mem_unit/reset_i
add wave -noupdate /cpu_tb/dut/mem_unit/execute_valid_i
add wave -noupdate /cpu_tb/dut/mem_unit/execute_packet_i
add wave -noupdate /cpu_tb/dut/mem_unit/rs_tag_i
add wave -noupdate /cpu_tb/dut/mem_unit/cdb_grant_i
add wave -noupdate /cpu_tb/dut/mem_unit/mem_addr_o
add wave -noupdate /cpu_tb/dut/mem_unit/mem_wdata_o
add wave -noupdate /cpu_tb/dut/mem_unit/mem_wr_en_o
add wave -noupdate /cpu_tb/dut/mem_unit/mem_rdata_i
add wave -noupdate /cpu_tb/dut/mem_unit/result_o
add wave -noupdate /cpu_tb/dut/mem_unit/busy_o
add wave -noupdate /cpu_tb/dut/mem_unit/packet_r
add wave -noupdate /cpu_tb/dut/mem_unit/tag_r
add wave -noupdate /cpu_tb/dut/mem_unit/valid_r
add wave -noupdate /cpu_tb/dut/dmem/clk_i
add wave -noupdate /cpu_tb/dut/dmem/wr_en_i
add wave -noupdate /cpu_tb/dut/dmem/addr_i
add wave -noupdate /cpu_tb/dut/dmem/data_i
add wave -noupdate /cpu_tb/dut/dmem/data_o
add wave -noupdate /cpu_tb/dut/dmem/cycle_count
add wave -noupdate -divider -height 31 COMMON_DATA_BUS
add wave -noupdate /cpu_tb/dut/cdb_ctrl/clk_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/reset_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/alu_result_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/mult_result_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/div_result_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/mem_result_i
add wave -noupdate /cpu_tb/dut/cdb_ctrl/cdb_packet_o
add wave -noupdate /cpu_tb/dut/cdb_ctrl/alu_grant_o
add wave -noupdate /cpu_tb/dut/cdb_ctrl/mult_grant_o
add wave -noupdate /cpu_tb/dut/cdb_ctrl/div_grant_o
add wave -noupdate /cpu_tb/dut/cdb_ctrl/mem_grant_o
add wave -noupdate /cpu_tb/dut/cdb_ctrl/request_vector
add wave -noupdate /cpu_tb/dut/cdb_ctrl/grant_vector
add wave -noupdate -divider -height 31 COMMIT_STAGE
add wave -noupdate /cpu_tb/dut/commit_stage_inst/clk_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/reset_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/flush_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/issue_valid_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/issue_opcode_i
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_stage_inst/issue_dest_reg_i
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_stage_inst/issue_pc_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/issue_is_branch_i
add wave -noupdate -childformat {{/cpu_tb/dut/commit_stage_inst/cdb_packet_i.branch_target -radix unsigned}} -expand -subitemconfig {/cpu_tb/dut/commit_stage_inst/cdb_packet_i.branch_target {-radix unsigned}} /cpu_tb/dut/commit_stage_inst/cdb_packet_i
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_valid_o
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_stage_inst/commit_dest_reg_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_value_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_rob_entry_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_is_store_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_is_branch_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/commit_branch_taken_o
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_stage_inst/commit_branch_target_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_full_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_empty_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_tail_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/branch_mispredict_o
add wave -noupdate -radix unsigned /cpu_tb/dut/commit_stage_inst/correct_pc_o
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_head
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_tail
add wave -noupdate /cpu_tb/dut/commit_stage_inst/rob_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {165 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
configure wave -valuecolwidth 125
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {280 ps}
