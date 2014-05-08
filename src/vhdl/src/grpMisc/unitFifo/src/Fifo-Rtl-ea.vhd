-------------------------------------------------------------------------------
-- Title      : Fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Fifo-Rtl-ea.vhd
-- Author     : Lukas Schuller  <l.schuller@gmail.com>
-- Company    : 
-- Created    : 2013-12-20
-- Last update: 2014-04-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: FIFO to be used with DataPorts
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-12-20  1.0      lukas   Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library	global;
use global.Global.all;


entity Fifo is
  
  generic (
    gDepth : natural
    );
  port (
    iClk         : in  std_ulogic;
    inResetAsync : in  std_ulogic;
    iDin         : in  aDataPort;
    oAck         : out std_ulogic;
    oDout        : out aDataPort;
    iAck         : in  std_ulogic);

end entity Fifo;

architecture Rtl of Fifo is

  subtype aWord is std_ulogic_vector(cEmptyPortVec'range);
  type aMemory is array (0 to gDepth-1) of aWord;

  subtype aPointer is unsigned(LogDualis(gDepth-1) downto 0);

  signal RdPtr  : aPointer := (others => '0');  -- to avoid metavalue warning
  signal WrPtr  : aPointer := (others => '0');  -- to avoid metavalue warning
  signal Memory : aMemory;

  signal sEmpty, sFull : std_ulogic;
  
  
begin  -- architecture Rtl


  sEmpty <= '1' when WrPtr = RdPtr else
            '0';
  sFull <= '1' when WrPtr+1 = RdPtr else
           '0';

  oAck   <= iDin.Valid and not sFull;

  oDout <= ToDataPort(Memory(to_integer(RdPtr)), not sEmpty) when not sEmpty else
           cEmptyPort;
    
  ReadWrite : process (iClk, inResetAsync) is
  begin  -- process ReadWrite
    if inResetAsync = '0' then          -- asynchronous reset (active low)
      RdPtr <= (others => '0');
      WrPtr <= (others => '0');
    elsif rising_edge(iClk) then        -- rising clock edge
      
      if iDin.Valid = '1' and sFull = '0' then
        Memory(to_integer(WrPtr)) <= ToSulv(iDin);
        WrPtr <= WrPtr + 1;
      end if;

      if sEmpty = '0' and iAck = '1' then
        RdPtr <= RdPtr + 1;
      end if;
      
    end if;
  end process ReadWrite;
  

end architecture Rtl;
