
///////////////////////////////////////
class transaction;
 randc bit [3:0] a;
 randc bit [3:0] b;
  bit [4:0] sum;
  
  function void display();
    $display("a : %0d \t b: %0d \t sum : %0d",a,b,sum);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.a = this.a;
    copy.b = this.b;
    copy.sum = this.sum;
  endfunction
  
endclass
 ///////////////////////////////////////////////////////
 
class generator;
  
  transaction trans;
  mailbox #(transaction) mbx;
  event done,nxt;
  
  
  
  function new(mailbox #(transaction) mbx,event nxt);
    this.mbx = mbx;
    trans = new();
   this.nxt=nxt;
  endfunction
  
  
  task run();
    for(int i = 0; i<10; i++) begin
     
      trans.randomize();
      
      $display("[GEN] : DATA SENT TO DRIVER");
      trans.display();
        mbx.put(trans.copy);
      #5;
      wait(nxt.triggered);// for HAND_SHAKING with DUT
    
    end
   -> done;
  endtask
  
  
endclass
///////////////////////////////////////////////////////////////////////// 
interface add_if;
    logic [4:0] sum;
  logic [3:0] a;
  logic [3:0] b;

  logic clk;
endinterface
 ///////////////////////////////////////////////////////////////////////////
class driver;
  
  virtual add_if aif;
  mailbox #(transaction) mbx;
  transaction data;
  event next;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction 
  
  
  task run();
  forever begin
    mbx.get(data);

    @(posedge aif.clk); 
    aif.a <= data.a;
    aif.b <= data.b;

  
    @(posedge aif.clk); 
    #1;// Allow the DUT’s sum output to settle before checking or using it.
   data.sum = aif.sum ;  
    $display("[DRV] : Interface Trigger");
    data.display();

    -> next;
    
  end
endtask  
endclass
 ////////////////////////////////////////////////////////////////////////// 
module tb;
  
 add_if aif();
 driver drv;
 generator gen;
event done,next;  
mailbox #(transaction) mbx;
  
add dut (aif.sum, aif.a, aif.b, aif.clk );
  
  initial begin
    aif.clk <= 0;
  end
  
  always #20 aif.clk <= ~aif.clk;
 
   initial begin
     mbx = new();
     drv = new(mbx);
     next=drv.next;
     gen = new(mbx,next);
     drv.aif = aif;
     done = gen.done;    
   end
  
  initial begin
  fork
    gen.run();
    drv.run();
  join_none
    wait(done.triggered);
    $finish();
  end
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;  
  end
  
endmodule