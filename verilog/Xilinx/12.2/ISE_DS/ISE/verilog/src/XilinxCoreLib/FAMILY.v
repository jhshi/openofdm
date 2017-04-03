/* $Header: /devl/xcs/repo/env/Databases/ip/src/com/xilinx/ip/unisim/simulation/FAMILY.v,v 1.19 2008/09/08 20:10:25 akennedy Exp $
--
-- Description - 
*/

`define any       "any"
`define x4k       "x4k"
`define x4ke      "x4ke"
`define x4kl      "x4kl"
`define x4kex     "x4kex"
`define x4kxl     "x4kxl"
`define x4kxv     "x4kxv"
`define x4kxla    "x4kxla"
`define spartan   "spartan"
`define spartanxl "spartanxl"
`define spartan2  "spartan2"
`define spartan2e "spartan2e"
`define virtex    "virtex"
`define virtexe   "virtexe"
`define virtex2   "virtex2"
`define virtex2p  "virtex2p"
`define spartan3  "spartan3"
`define spartan3a "spartan3a"
`define spartan3adsp "spartan3adsp"
`define spartan3e "spartan3e"
`define aspartan3e "aspartan3e"
`define aspartan3 "aspartan3"
`define virtex4   "virtex4"
`define virtex5   "virtex5"
`define qrvirtex  "qrvirtex"
`define qrvirtex2 "qrvirtex2"
`define qvirtex   "qvirtex"
`define qvirtex2  "qvirtex2"
`define qvirtexe  "qvirtexe"

module family ( );

/*
 * True if architecture "child" is derived from, or equal to,
 * the architecture "ancestor".
 * ANY, X4K, SPARTAN, SPARTANXL
 * ANY, X4K, X4KE, X4KL
 * ANY, X4K, X4KEX, X4KXL, X4KXV, X4KXLA
 * ANY, VIRTEX, SPARTAN2, SPARTAN2E
 * ANY, VIRTEX, VIRTEXE
 * ANY, VIRTEX, VIRTEX2, SPARTAN3, ASPARTAN3E
 * ANY, VIRTEX, VIRTEX2, SPARTAN3, SPARTAN3A, SPARTAN3ADSP
 * ANY, VIRTEX, VIRTEX2, SPARTAN3, ASPARTAN3
 * ANY, VIRTEX, VIRTEX2, VIRTEX2P
 * ANY, VIRTEX, VIRTEX5
 * ANY, VIRTEX, VIRTEX4
 * ANY, VIRTEX, QRVIRTEX
 * ANY, VIRTEX, VIRTEX2, QRVIRTEX2
 * ANY, VIRTEX, QVIRTEX
 * ANY, VIRTEX, VIRTEX2, QVIRTEX2
 * ANY, VIRTEX, QVIRTEX
 */

function derived;
    input [9*8:1] child;
    input [9*8:1] ancestor;
    begin
        derived = 0;
        if ( child == `virtex ) 
	begin
	    if ( ancestor == `virtex || ancestor == `any )
	    begin
                derived = 1;
            end
	end
    else if ( child == `qvirtexe )
    begin
        if ( ancestor == `qvirtexe || ancestor == `virtex || ancestor == `any )
        begin
            derived = 1;
        end
    end
    else if ( child == `qvirtex2 )
    begin
        if ( ancestor == `qvirtex2 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
        begin
            derived = 1;
        end
    end
    else if ( child == `qvirtex )
    begin
        if ( ancestor == `qvirtex || ancestor == `virtex || ancestor == `any )
        begin
            derived = 1;
        end
    end
    else if ( child == `qrvirtex2 )
    begin
        if ( ancestor == `qrvirtex2 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
        begin
            derived = 1;
        end
    end
    else if ( child == `qrvirtex )
    begin
        if ( ancestor == `qrvirtex || ancestor == `virtex || ancestor == `any )
        begin
            derived = 1;
        end
    end
	else if ( child == `virtex5 )
	begin
	    if ( ancestor == `virtex5 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end	    
	end
	else if ( child == `virtex4 )
	begin
	    if ( ancestor == `virtex4 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end	    
	end
	else if ( child == `virtex2 )
	begin
	    if ( ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
                derived = 1;
            end
	end
	else if ( child == `virtex2p )
	begin
	    if ( ancestor == `virtex2p || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `spartan3e )
	begin
	    if ( ancestor == `spartan3e || ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `aspartan3e )
	begin
	    if ( ancestor == `aspartan3e || ancestor == `spartan3e || ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `spartan3a )
	begin
	    if ( ancestor == `spartan3a || ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `spartan3adsp )
	begin
	    if ( ancestor == `spartan3adsp || ancestor == `spartan3a || ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `aspartan3 )
	begin
	    if ( ancestor == `aspartan3 || ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `spartan3 )
	begin
	    if ( ancestor == `spartan3 || ancestor == `virtex2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `virtexe )
	begin
	    if ( ancestor == `virtexe || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end	    
	end
	else if ( child == `spartan2 )
	begin
	    if ( ancestor == `spartan2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
	else if ( child == `spartan2e )
	begin
	    if ( ancestor == `spartan2e || ancestor == `spartan2 || ancestor == `virtex || ancestor == `any )
	    begin
	        derived = 1;
            end
	end
        else if ( child == `x4k )
	begin
            if ( ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `x4kex )
	begin
            if ( ancestor == `x4kex || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `x4kxl )
	begin
            if ( ancestor == `x4kxl || ancestor == `x4kex || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `x4kxv )
	begin
            if ( ancestor == `x4kxv || ancestor == `x4kxl || ancestor == `x4kex || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `x4kxla )
	begin
            if ( ancestor == `x4kxla || ancestor == `x4kxv || ancestor == `x4kxl || ancestor == `x4kex || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `x4ke )
	begin
            if ( ancestor == `x4ke || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end 	    
	end
        else if ( child == `x4kl )
	begin
            if ( ancestor == `x4kl || ancestor == `x4ke || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `spartan )
	begin
            if ( ancestor == `spartan || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `spartanxl )
	begin
            if ( ancestor == `spartanxl || ancestor == `spartan || ancestor == `x4k || ancestor == `any )
	    begin
                derived = 1;
            end
	end
        else if ( child == `any )
	begin
            if ( ancestor == `any )
	    begin
                derived = 1;
            end
	end
    end
endfunction //my_func

endmodule
