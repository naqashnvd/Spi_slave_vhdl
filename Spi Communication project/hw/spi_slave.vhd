library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity spi_slave is 
    generic (
        bW: integer:= 16
    );
    port(
        clk: in std_logic; -- Board clock
        aresetn: in std_logic; -- active low asyncoronous reset
        
        -- Control Interface
        -- Slave interface 
        -- Data to send on SPI
        s_axis_tdata: in std_logic_vector(bW-1  downto 0);
        s_axis_tvalid: in std_logic; -- data is valid 
        s_axis_tready: out std_logic; -- Ready for the input
        -- Master Interface
        -- Data recieved from SPI
        m_axis_tdata: out std_logic_vector(bW-1 downto 0);
        m_axis_tvalid: out std_logic;
        
        -- SPI interface 
        spi_sclk: in std_logic;
        spi_csn: in std_logic;
        spi_mosi: in std_logic;
        spi_miso: out std_logic
    );
end spi_slave;

architecture arch_spi_slave of spi_slave is 
    -- Intermediate signals
    constant bW_len: integer:= integer(ceil(log2(real(bW))));
    signal count: unsigned(bW_len downto 0):= (others => '0');
    
    signal s_axis_tdata_reg: std_logic_vector(bW-1 downto 0):= (others => '0');
    signal spi_csn_reg: std_logic;
    signal spi_mosi_reg: std_logic;

    signal sclk_reg1: std_logic:= '0';
    signal sclk_reg2: std_logic:= '0';
    signal sclk_flag: std_logic;
    signal sclk_flag_l: std_logic;

    signal temp_recv: std_logic_vector(bW-1 downto 0):= (others => '0');
    signal temp_send: std_logic_vector(bW-1 downto 0):= (others => '0');

    type states is(
        state_idle,
        state_busy,
        state_done
    );

    signal state: states := state_idle;

begin
    -- Register Inputs
    -- Register slave Input on slave valid when ip is ready to accept slave data
    process(clk, aresetn, s_axis_tdata) begin
        if(aresetn = '0') then
            s_axis_tdata_reg <= (others => '0');
            spi_csn_reg <= '0';
            spi_mosi_reg <= '0';
        elsif rising_edge(clk) then
            if(s_axis_tvalid = '1' AND state = state_idle) then
                s_axis_tdata_reg <= s_axis_tdata;
            else
                s_axis_tdata_reg <= s_axis_tdata_reg;
            end if;
            spi_csn_reg <= spi_csn;
            spi_mosi_reg <= spi_mosi;
        end if;
    end process;

    -- Detect the rising edge of sclk (master clock)
    -- and generate a flag for only one board clock cycle
    process(clk, aresetn, spi_sclk, sclk_reg1) begin
        if(aresetn = '0') then
            sclk_reg1 <= '0';
            sclk_reg2 <= '0';
        elsif rising_edge(clk) then
            sclk_reg1 <= spi_sclk;
            sclk_reg2 <= sclk_reg1;
        end if;
    end process;
    sclk_flag <= sclk_reg1 AND (NOT sclk_reg2); -- detect rising edge 
    sclk_flag_l <=  sclk_reg2 AND (NOT sclk_reg1); -- detect falling edge

    -- SPI
    process(clk, aresetn, spi_csn_reg, state, sclk_flag, sclk_flag_l, count, spi_mosi_reg) begin
        if(aresetn = '0') then
            state <= state_idle;
            count <= (others => '0');
            temp_recv <= (others => '0');
            temp_send <= (others => '0');
        elsif rising_edge(clk) then
            case(state) is
                when state_idle => -- waiting for Chip select
                    if(spi_csn_reg = '0') then
                        state <= state_busy;
                    else 
                        state <= state_idle;
                    end if;
                    count <= (others=>'0');
                    temp_recv <= (others => '0');
                    temp_send <= s_axis_tdata_reg;
                
                when state_busy =>  -- Start the SPI transaction
                    if(spi_csn_reg = '0') then
                        if(sclk_flag = '1') then
                            state <= state_busy;
                            count <= count + 1;
                            -- Shifting registers
                            -- register mosi on rising edge
                            temp_recv(bW-1 downto 0) <= temp_recv(bW-2 downto 0) & spi_mosi_reg;
                        elsif(sclk_flag_l = '1' AND count /= bW) then
                            state <= state_busy;
                            count <= count;
                            temp_recv <= temp_recv;
                            -- Shifting registers
                            -- change miso on falling edge
                            temp_send(bW-1 downto 0) <= temp_send(bW-2 downto 0) & '0';
                        elsif(sclk_flag_l = '1' AND count = bW) then -- transcation complete
                            state <= state_done;
                            count <= count;
                            temp_recv <= temp_recv;
                            temp_send <= temp_send;
                        else 
                            state <= state_busy;
                            count <= count;
                            temp_recv <= temp_recv;
                            temp_send <= temp_send;
                        end if;
                    else -- transcation doesnt complete
                        state <= state_idle;
                        count <= (others=>'0');
                        temp_recv <= (others => '0');
                        temp_send <= (others => '0');
                    end if;
                
                when state_done => -- SPI Transction is done
                    state <= state_idle;
                    count <= (others=>'0');
                    temp_recv <= temp_recv;
                    temp_send <= temp_send;

                when others => 
                    state <= state_idle;
                    count <= (others=>'0');
                    temp_recv <= (others => '0');
                    temp_send <= (others => '0');
            end case;
        end if;
    end process;

    -- Outputs
    spi_miso <= temp_send(bW-1) when state = state_busy else '1';

    process(clk, state, aresetn, temp_recv) begin
        if(aresetn = '0') then
            m_axis_tdata <= (others => '0');
            m_axis_tvalid <= '0';
            s_axis_tready <= '0';
        elsif rising_edge(clk) then
            case(state) is
                when state_idle => 
                    -- m_axis_tdata <= ;
                    m_axis_tvalid <= '0';
                    s_axis_tready <= '1';

                when state_busy => 
                    -- m_axis_tdata <= ;
                    m_axis_tvalid <= '0';
                    s_axis_tready <= '0';

                when state_done => 
                    m_axis_tdata <= temp_recv;
                    m_axis_tvalid <= '1';
                    s_axis_tready <= '0';
            
                when others => 
                    m_axis_tdata <= (others => '0');
                    m_axis_tvalid <= '0';
                    s_axis_tready <= '0';
            end case;
        end if;
    end process;

end arch_spi_slave;