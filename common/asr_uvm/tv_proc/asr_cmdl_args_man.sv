class asr_cmdl_args_man #(type T = int) extends `TV_BASE_OBJ;
    typedef asr_cmdl_args_man#(T) this_type;
    static local this_type m_inst;

    function new(input string name="unnamed-asr_cmdl_args_man");
        super.new(name);
    endfunction

    static function this_type get();
        if(m_inst == null)
            m_inst = new("ASR_CMDL_ARGS_MAN");
        return m_inst;
    endfunction

    static function bit get_arg_from_cmdl(string _arg, string _arg_format, ref T _t);
        if($value$plusargs($psprintf("%s=%s", _arg, _arg_format), _t)) begin
            `asr_print($psprintf($psprintf("ASR_CMDL_ARGS_MAN @%0t get %s with val %s from cmd line",$time,_arg,_arg_format),_t))
            return 1'b1;
        end else begin
            `asr_print($psprintf("ASR_CMDL_ARGS_MAN @%0t can't get %s from cmd line",$time,_arg))
            return 1'b0;
        end
    endfunction

endclass
