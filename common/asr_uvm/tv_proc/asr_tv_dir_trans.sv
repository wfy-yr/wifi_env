class asr_tv_dir_trans extends `TV_BASE_OBJ;//{{{
    string   case_path;
    string   sub_dir = "";
    string   file_name = "";
    rand int multi_tv_idx;
    `ifdef USING_UVM_METH
        `uvm_object_utils_begin(asr_tv_dir_trans)
        `uvm_field_string(case_path, UVM_ALL_ON)
        `uvm_field_string(sub_dir, UVM_ALL_ON)
        `uvm_field_string(file_name, UVM_ALL_ON)
        `uvm_field_int(multi_tv_idx, UVM_ALL_ON + UVM_DEC)
        `uvm_object_utils_end
    `endif
    function new(string name = "asr_tv_dir_trans");
        super.new(name);
    endfunction
    virtual function string get_dir();
        return "";
    endfunction
    virtual function string get_full_dir();
        return {get_dir(),"/",sub_dir,"/"};
    endfunction

    virtual function string get_full_path();
        return {get_dir(),"/",sub_dir,"/",file_name};
    endfunction

    virtual function bit dir_match(asr_tv_dir_trans rhs);
        return 1'b1;
    endfunction
    virtual function bit is_condition_match();
        return 1'b1;
    endfunction

    virtual function void cp_to_trans(ref asr_tv_dir_trans rhs);
        if(rhs !== null) begin
            rhs.case_path = this.case_path;
            rhs.sub_dir = this.sub_dir;
            rhs.file_name = this.file_name;
        end
    endfunction
endclass//}}}
