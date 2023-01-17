typedef asr_tv_dir_trans asr_dir_q[$]; 
class asr_tv_proc extends `TV_BASE_OBJ;//{{{
    protected string m_parent = "";
    protected string m_case_path = "";

    asr_dir_q m_cfg_info_q;
    protected asr_dir_q m_file_q[string]; 
    protected asr_dir_q m_q_db[string]; 

    protected string m_case_path_lst[$];
    protected int m_case_path_cnt = 0; 
    protected bit case_id_compl_en = 1'b1;
    protected bit has_parsed = 1'b1;
    bit multi_tv_recycle_mode = 1'b0;

    string reg_cfg_name_remap[string];

    `ifdef USING_UVM_METH
        `uvm_object_utils(asr_tv_proc)
    `endif
    extern function new(string name="unnamed-asr_tv_proc");
    extern function void set_case_path(string _path);
    extern function string get_case_path();
    extern function void reset();
    extern function void set_parent(string _parent);
    extern function string get_parent_name();
    extern function void set_case_id_compl_en(bit _en);
    extern virtual function void set_default(input int tot_frm = 20);
    extern virtual function void get_tv_list();
    extern virtual function bit parse_case_dir(ref asr_tv_dir_trans dir_q[$], input int tot_frm = 20, input string case_path = "", input int multi_tv_dir = 0);
    extern virtual function bit get_all_tv_dir_q(ref asr_tv_dir_trans dir_q[$], input int tot_frm = 20);
    extern virtual function bit scan_directory_for_file(input string fname_q[$], input string sub_match = "", input int tot_frm = 20);
    extern virtual function bit get_filelist_in_dir(string dir_name, string fname, ref string dirname_q[$]);
    extern virtual function bit read_reg_cfg_tv(string reg_cfg_fname, ref bit [31:0] reg_aa[string], input bit same_ovr = 1'b1);
    extern virtual function void read_single_col_tv(input string tv_fname, ref bit [`DW-1:0] data_queue[$], input int str_line = 0, input int read_line_num = -1);
    extern virtual function bit is_path_match(string pat_str, string src_str[$], ref string match_str_q[$], input bit match_str_mode = 1'b1);
    extern virtual function automatic bit sg_is_dir_legal(string path, bit print_en = 1'b0);
    extern virtual function automatic bit sg_is_path_legal(string path, bit print_en = 1'b0);
    extern virtual function automatic string sg_rm_str_from_str(string pat_str="", string src_str, bit rm_mode = 0); //0: just remove 1st match; 1: remove all match
    extern virtual function automatic bit sg_is_str_match(string pat_str, string src_str);

endclass//}}}

function asr_tv_proc::new(string name="unnamed-asr_tv_proc");
   super.new(name);
endfunction : new

function void asr_tv_proc::set_case_path(string _path);//{{{
    m_case_path = _path;
endfunction//}}}

function string asr_tv_proc::get_case_path();//{{{
    return m_case_path;
endfunction//}}}

function void asr_tv_proc::reset();//{{{
    m_cfg_info_q.delete();
endfunction//}}}

function void asr_tv_proc::set_parent(string _parent);//{{{
    m_parent = _parent;
endfunction//}}}

function string asr_tv_proc::get_parent_name();//{{{
    return m_parent;
endfunction//}}}

function void asr_tv_proc::set_case_id_compl_en(bit _en);//{{{
    this.case_id_compl_en = _en;
endfunction//}}}

function void asr_tv_proc::set_default(input int tot_frm = 20);//{{{
    bit is_case_path_got;
    if(!asr_cmdl_args_man#(string)::get_arg_from_cmdl("TV_PATH","%s",m_case_path)) begin
        string case_id;
        string tv_dir;
        if(asr_cmdl_args_man#(string)::get_arg_from_cmdl("CASE_ID","%s",case_id) &&
           asr_cmdl_args_man#(string)::get_arg_from_cmdl("TV_DIR","%s",tv_dir)) begin
            int id_len = case_id.len();
            m_case_path = {tv_dir, "Case"};
            if(case_id_compl_en && id_len <= 4) begin
                repeat(4-id_len) m_case_path = {m_case_path,"0"};
            end
            m_case_path = {m_case_path, case_id};
            is_case_path_got = 1'b1;
        end else begin
            `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t can't get case path from cmd line", get_parent_name(),$time))
        end
    end else begin
        is_case_path_got = 1'b1;
    end
    if(m_case_path_lst.size() == 0) begin
        get_tv_list(); 
    end
    if(is_case_path_got && (m_case_path_lst.size() == 0))begin
        if(!has_parsed) begin
            if(!parse_case_dir(m_cfg_info_q,tot_frm)) begin
                `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t parse case dir failed", get_parent_name(),$time))
            end
            has_parsed = 1'b1;
        end
    end else begin
        if(!has_parsed) begin
            if(!get_all_tv_dir_q(m_cfg_info_q,tot_frm)) begin
                `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t parse case dir for multi failed", get_parent_name(),$time))
            end
            has_parsed = 1'b1;
        end
    end
endfunction//}}}

function void asr_tv_proc::get_tv_list();//{{{
    string  tv_list;
    integer handle;
    int     ret;
    string  cmd;
    string  tv_lst_dir;
    if(asr_cmdl_args_man#(string)::get_arg_from_cmdl("TV_LST","%s",tv_list)) begin
        if(tv_list == "") begin
            `asr_print_error($psprintf("ASR_TV_PROC[%0s]@%0t tv list from cmd line is empty", get_parent_name(),$time))
        end else begin
            if(sg_is_path_legal(tv_list)) begin
                handle = $fopen(tv_list,"r");
                while(!$feof(handle))begin
                    string _str;
                    ret = $fscanf(handle,"%s\n",_str);
                    `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t str=%s", get_parent_name(),$time,_str))
                    m_case_path_lst.push_back(_str);
                end
                $fclose(handle);
            end
        end
    end else if(asr_cmdl_args_man#(string)::get_arg_from_cmdl("TV_LST_DIR","%s",tv_lst_dir)) begin
        if(tv_lst_dir == "") begin
            `asr_print_error($psprintf("ASR_TV_PROC[%0s]@%0t tv list dir from cmd line is empty", get_parent_name(),$time))
        end else begin
            if(sg_is_dir_legal(tv_lst_dir)) begin
                cmd = $sformatf("ls %s > ./file.list", tv_lst_dir);
                `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t cmd=%s", get_parent_name(),$time,cmd))
                ret = $system(cmd);
                handle = $fopen("./file_list","r");
                while(!$feof(handle))begin
                    string _str;
                    ret = $fscanf(handle,"%s\n",_str);
                    _str = {tv_lst_dir, "/", _str};
                    m_case_path_lst.push_back(_str);
                end
                $fclose(handle);
                cmd = $sformatf("\rm -rf ./file.list");
                ret = $system(cmd);
            end
        end
    end
endfunction//}}}

function bit asr_tv_proc::parse_case_dir(ref asr_tv_dir_trans dir_q[$], input int tot_frm = 20, input string case_path = "", input int multi_tv_dir = 0);//{{{
    return 1'b0;
endfunction//}}}

function bit asr_tv_proc::get_all_tv_dir_q(ref asr_tv_dir_trans dir_q[$], input int tot_frm = 20);//{{{
    for(int i = 0; i< m_case_path_lst.size(); i++) begin
        string path = m_case_path_lst[i];
        void'(parse_case_dir(dir_q,tot_frm,path,i));
    end
    return dir_q.size() >0;
endfunction//}}}

function bit asr_tv_proc::scan_directory_for_file(input string fname_q[$], input string sub_match = "", input int tot_frm = 20);//{{{
    string path_q[$] = m_case_path_lst;
    if(fname_q.size() == 0) begin
        `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t no file is ready for scanning with", get_parent_name(), $time))
        return 1'b0;
    end
    if(m_cfg_info_q.size() == 0) begin
        if(m_case_path_lst.size()) begin
            if(multi_tv_recycle_mode) begin
                void'(parse_case_dir(m_cfg_info_q,tot_frm));
            end else begin
                void'(get_all_tv_dir_q(m_cfg_info_q,tot_frm));
            end
        end else begin
            void'(parse_case_dir(m_cfg_info_q,tot_frm));
        end
    end
    foreach(fname_q[i]) begin
        string dirname_q[$];
        if(m_file_q.exists({fname_q[i],"_",sub_match})) begin
            continue;
        end
        while(1) begin
            string impl_case_path;
            if(m_case_path_lst.size() == 0) begin
                impl_case_path = get_case_path();
            end else begin
                if(multi_tv_recycle_mode) begin
                    impl_case_path = get_case_path();
                end else begin
                    impl_case_path = path_q.pop_front();
                end
            end
            if(get_filelist_in_dir(impl_case_path,fname_q[i],dirname_q)) begin
                for(int j = 0; j< m_cfg_info_q.size(); j++) begin
                    string s;
                    string match_path[$];
                    if(sub_match == "") begin
                        s = {m_cfg_info_q[j].get_dir(),".*",fname_q[i]};
                    end else begin
                        s = {m_cfg_info_q[j].get_dir(),".*",sub_match,".*",fname_q[i]};
                    end
                    if(is_path_match(s,dirname_q,match_path)) begin
                        int k;
                        foreach(match_path[k]) begin
                            asr_tv_dir_trans dir;
                            m_cfg_info_q[i].cp_to_trans(dir);
                            dir.file_name = fname_q[i];
                            dir.sub_dir = sg_rm_str_from_str(m_cfg_info_q[j].get_dir(),match_path[k]);
                            if(!dir.is_condition_match())
                                continue;
                            dir.sub_dir = sg_rm_str_from_str(fname_q[i],dir.sub_dir);
                            m_file_q[{fname_q[i],"_",sub_match}].push_back(dir);
                        end
                    end
                end
            end
            if(path_q.size() == 0 || (path_q.size() && multi_tv_recycle_mode))
                break;
        end
    end
    return (m_file_q.size()>0);
endfunction//}}}

function bit asr_tv_proc::get_filelist_in_dir(string dir_name, string fname, ref string dirname_q[$]);//{{{
    if(sg_is_dir_legal(dir_name)) begin
        string cmd;
        int ret;
        cmd = $sformatf("find -L %s -name %s > ./file.list", dir_name, fname);
        ret = $system(cmd);
        if(sg_is_path_legal("file.list")) begin
            int handle;
            string str;
            handle = $fopen("./file.list","r");
            while(!$feof(handle))begin
                void'($fscanf(handle,"%s\n",str));
                dirname_q.push_back(str);
            end
            $fclose(handle);
            cmd = $sformatf("\rm -rf ./file.list");
            ret = $system(cmd);
        end
    end
    return (dirname_q.size() > 0);
endfunction//}}}

function bit asr_tv_proc::read_reg_cfg_tv(string reg_cfg_fname, ref bit [31:0] reg_aa[string], input bit same_ovr = 1'b1);//{{{
    int handle;
    int ret;
    bit [31:0] reg_aa_tmp[string];
    int        same_num_aa[string];
    if(sg_is_path_legal(reg_cfg_fname)) begin
        handle = $fopen(reg_cfg_fname,"r");
        while(!$feof(handle)) begin
            bit [31:0] _data;
            string     _s;
            ret = $fscanf(handle,"%s %h\n",_s,_data);
            if(ret == -1) begin
                `asr_print_error($psprintf("ASR_TV_PROC[%0s]@%0t format doesn't match", get_parent_name(), $time)) 
                continue;
            end
            if(same_ovr) begin
                reg_aa[_s] = _data;
            end else begin
                if(reg_aa_tmp.exists(_s))begin
                    if(same_num_aa[_s] == 0) begin
                        reg_aa[{_s,"-",$psprintf("%0d",same_num_aa[_s])}] = reg_aa[_s];
                        reg_aa.delete(_s);
                    end
                    same_num_aa[_s] += 1;
                    reg_aa[{_s,"-",$psprintf("%0d",same_num_aa[_s])}] = _data;
                end else begin
                    reg_aa_tmp[_s] = _data;
                    reg_aa[_s] = _data;
                    same_num_aa[_s] = 0;
                end
            end
        end
        $fclose(handle);
        return 1'b1;
    end else begin
        `asr_print_error($psprintf("ASR_TV_PROC[%0s]@%0t reg cfg full path %0s is not legal", get_parent_name(), $time, reg_cfg_fname))
    end
    return 1'b0;
endfunction//}}}

function void asr_tv_proc::read_single_col_tv(input string tv_fname, ref bit [`DW-1:0] data_queue[$], input int str_line = 0, input int read_line_num = -1);//{{{
   bit [`DW-1:0]   col_data;
   integer     data_file_ptr;
   integer     data_line_flg;
   
   if(sg_is_path_legal(tv_fname)) begin
       data_file_ptr = $fopen(tv_fname, "r");
       while(!$feof(data_file_ptr)) begin
          data_line_flg = $fscanf(data_file_ptr,"%h\n", col_data);
          if(data_line_flg == -1) begin
              `asr_print_error($psprintf("ASR_TV_PROC[%0s]@%0t READ_SINGLE_COL_TV file %s doesn't match", get_parent_name(), $time, tv_fname))
              return;
          end else begin
          	  data_queue.push_back(col_data);
          end
       end
       $fclose(data_file_ptr);
       if((str_line > 0 || (str_line == 0 && read_line_num > 0)) && str_line + read_line_num <= data_queue.size())begin
           if(read_line_num == -1)
               data_queue = data_queue[str_line:$];
           else
               data_queue = data_queue[str_line:(str_line + read_line_num -1)];
       end
       `asr_print($psprintf("ASR_TV_PROC[%0s]@%0t READ_SINGLE_COL_TV data_queue.size = %0d", get_parent_name(),$time,data_queue.size()))
   end
endfunction : read_single_col_tv //}}}

function bit asr_tv_proc::is_path_match(string pat_str, string src_str[$], ref string match_str_q[$], input bit match_str_mode = 1'b1);//{{{
   foreach(src_str[i]) begin
       //Regex re = regex_match(src_str[i],pat_str);
       if(uvm_re_match(src_str[i],pat_str)) begin
           if(match_str_mode)
               match_str_q.push_back(src_str[i]);
           else
               //match_str_q.push_back(re.getMatchString());
               match_str_q.push_back(uvm_glob_to_re(pat_str));
       end
   end
   return (match_str_q.size()>0);
endfunction//}}}

function automatic bit asr_tv_proc::sg_is_str_match(string pat_str, string src_str);
    string s_;
    if(src_str.len() == 0) begin
        return 1'b0;
    end else begin
        if(pat_str.len() == 0)begin
            return 1'b1;
        end else if(src_str.len() < pat_str.len()) begin
            return 1'b0;
        end else begin
            for(int i=0; i<src_str.len(); i++) begin
                s_ = src_str.substr(i,i+pat_str.len()-1);
                if(pat_str == s_)
                    return 1'b1;
            end
            return 1'b0;
        end
    end
endfunction

function automatic bit asr_tv_proc::sg_is_dir_legal(string path, bit print_en = 1'b0);
    //if(asr_file_accessible(path,'{r:1,w:0,x:0})) begin
    //    sys_fileMode_s fmode;
    //    fmode = file_mode(path);
    //    if(fmode.fType !== fTypeFile) begin
    //       return 1'b1;
    //    end
    //end else begin
    //    if(print_en)
    //        $display("%0s doesn't exits", path);
    //end
    return 1'b1;
endfunction

function automatic bit asr_tv_proc::sg_is_path_legal(string path, bit print_en = 1'b0);
    //if(asr_file_accessible(path,'{r:1,w:0,x:0})) begin
    //    sys_fileMode_s fmode;
    //    fmode = file_mode(path);
    //    if(fmode.fType !== fTypeFile) begin
    //       return 1'b1;
    //    end
    //end else begin
    //    if(print_en)
    //        $display("%0s doesn't exits", path);
    //end
    return 1'b1;
endfunction

function automatic string asr_tv_proc::sg_rm_str_from_str(string pat_str="", string src_str, bit rm_mode = 0); //0: just remove 1st match; 1: remove all match
    string s_;
    string l_p;
    string r_p;
    if(!sg_is_str_match(pat_str,src_str)) begin
        return src_str;
    end else begin
        string s_tmp = src_str;
        int i;
        while(i<s_tmp.len()) begin
            s_ = s_tmp.substr(i,i+pat_str.len()-1);
            if(pat_str == s_) begin
                l_p = s_tmp.substr(0,i-1);
                r_p = s_tmp.substr(i+pat_str.len(),s_tmp.len()-1);
                s_tmp = {l_p,r_p};
                i = 0;
                if(!rm_mode)
                    break;
            end else begin
                i++;
            end
        end
        return s_tmp;
    end
endfunction

//function automatic bit asr_file_accessible(string path, sys_fileRWX_s mode = 0);
//    int ok;
//    int err = svlib_dpi_imported_access(path, mode, ok);
//    return ok;
//endfunction
//
//function automatic sys_fileMode_s file_mode(string path, bit asLink = 0);
//    sys_fileStat_s stat = sys_fileStat(path, asLink);
//    return stat.mode;
//endfunction
//
//function automatic sys_fileStat_s sys_fileStat(string path, bit asLink = 0);
//    longint stats[statARRAYSIZE];
//    int err;
//    svlibErrorManager errorManager = error_getManager();
//    err = svlib_dpi_imported_fileStat(path,asLink,stats);
//    if(err)begin
//        errorManager.submit(err,$sformatf("sys_fileStat(.path(%s), .asLink(%b)): error in system call", str_quote(path), asLink));
//    end else begin
//        errorManager.submit(0);
//        sys_fileStat.mtime    = stats[statMTIME];
//        sys_fileStat.atime    = stats[statATIME];
//        sys_fileStat.ctime    = stats[statCTIME];
//        sys_fileStat.size     = stats[statSIZE];
//        sys_fileStat.mode     = stats[statMODE];
//        sys_fileStat.uid      = stats[statUID];
//        sys_fileStat.gid      = stats[statGID];
//    end
//endfunction
