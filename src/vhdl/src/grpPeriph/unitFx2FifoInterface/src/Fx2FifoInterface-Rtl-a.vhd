-------------------------------------------------------------------------------
-- Title      : FX2 Fifo Interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Fx22FifoInterface-Rtl-ea.vhd
-- Author     : Lukas Schuller  <l.schuller@gmail.com>
-- Company    : 
-- Created    : 2013-05-31
-- Last update: 2013-09-19
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: FX2 fifo interface
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-05-31  1.0      lukas   Created
-------------------------------------------------------------------------------

architecture Rtl of Fx2FifoInterface is

  signal
    sFifo2DataAvailable,
    sFifo3DataAvailable,
    sFifo4Full : std_ulogic;
--    sFifo5Full : std_ulogic;

  constant cEp2Adr : std_ulogic_vector := "00";
  constant cEp4Adr : std_ulogic_vector := "01";
  constant cEp6Adr : std_ulogic_vector := "10";
  constant cEp8Adr : std_ulogic_vector := "11";

  signal sFifoDin, sFifoDout     : std_ulogic_vector(7 downto 0);
  signal sDOutEnable, sDInEnable : std_ulogic;

  signal sFifoRd, sFifoWr : std_ulogic;

  constant cSynA : std_ulogic_vector(7 downto 0) := x"AA";
  constant cSynB : std_ulogic_vector(7 downto 0) := x"BB";
  constant cAckA : std_ulogic_vector(7 downto 0) := x"AB";
  constant cAckB : std_ulogic_vector(7 downto 0) := x"BC";

  type aFifoState is (Init, Idle, Rd, Wr, EopWaitState, FinalizePacket);

  type aRegSet is record
    State         : aFifoState;
    HostConnected : std_ulogic;
  end record;

  constant cRegInitval : aRegSet := (State         => Init,
                                     HostConnected => '0');

  signal R     : aRegSet := cRegInitval;
  signal NextR : aRegSet;
  
begin  -- Rtl

  sFifo2DataAvailable <= iFx2Flags(0);
--  sFifo3DataAvailable <= iFx2Flags(1);
  sFifo4Full          <= not iFx2Flags(2);
--  sFifo5Full          <= not iFx2PA7;

  ioFx2Data <= std_logic_vector(sFifoDout) when sDOutEnable = '1' else
               (others => 'Z');

  onFx2DataOe <= not sDInEnable when sDOutEnable = '0' else
                 '1';  -- deactivate fx2's oe when fpga's oe is set

  sFifoDin   <= std_ulogic_vector(ioFx2Data);
  oFx2Wakeup <= '1';

  oData     <= sFifoDin;
  sFifoDout <= iData;

  onFx2WrStrobe <= not sFifoWr;
  onFx2RdStrobe <= not sFifoRd;

  Comb : process (R, sFifo2DataAvailable, sFifo3DataAvailable, sFifoDin, sFifo4Full, iValid, iAck, iEndOfPacket)
  begin  -- process Comb
    NextR       <= R;
    oAck        <= '0';
    oValid      <= '0';
    sDInEnable  <= '0';
    sDOutEnable <= '0';
    sFifoWr     <= '0';
    sFifoRd     <= '0';
    onFx2PktEnd <= '1';
    oFx2FifoAdr <= cEp2Adr;

    case R.State is
      when Init =>
        onFx2PktEnd <= '0';
        NextR.State <= Idle;
        
      when Idle =>
        
        if iValid = '1' then            -- begin sending packet
          NextR.State <= Wr;
          
        elsif sFifo2DataAvailable = '1' then  -- offer data to read if available
          NextR.State <= Rd;
        end if;
        
      when Wr =>
        oFx2FifoAdr <= cEp6Adr;
        if iValid = '1' then
          if sFifo4Full = '0' then
            sDOutEnable <= '1';
            sFifoWr     <= '1';
            oAck        <= '1';
            if iEndOfPacket = '1' then
              onFx2PktEnd <= '0';
              NextR.State <= Idle;
            end if;
          end if;
        else
          --onFx2PktEnd <= '0';
          NextR.State <= Idle;
        end if;
        
        
   
      when Rd =>
        NextR.HostConnected <= '1';
        if sFifo2DataAvailable = '1' then
          oValid     <= '1';
          sDInEnable <= '1';
          sFifoRd    <= iAck;
        else
          NextR.State <= Idle;
        end if;

      when others =>
        NextR <= cRegInitval;

    end case;

    --end if;

  end process Comb;


  Reg : process (iFx2Clk, inResetAsync)
  begin  -- process Sync
    if inResetAsync = '0' then          -- asynchronous reset (active low)
      R <= cRegInitval;
    elsif iFx2Clk'event and iFx2Clk = '1' then  -- rising clock edge
      R <= NextR;
    end if;
  end process Reg;

end Rtl;

