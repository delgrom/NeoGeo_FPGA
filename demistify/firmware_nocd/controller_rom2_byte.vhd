
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"10",x"30",x"7c",x"7c"),
     1 => (x"60",x"30",x"10",x"00"),
     2 => (x"06",x"1e",x"78",x"60"),
     3 => (x"3c",x"66",x"42",x"00"),
     4 => (x"42",x"66",x"3c",x"18"),
     5 => (x"6a",x"38",x"78",x"00"),
     6 => (x"38",x"6c",x"c6",x"c2"),
     7 => (x"00",x"00",x"60",x"00"),
     8 => (x"60",x"00",x"00",x"60"),
     9 => (x"5b",x"5e",x"0e",x"00"),
    10 => (x"1e",x"0e",x"5d",x"5c"),
    11 => (x"f0",x"c2",x"4c",x"71"),
    12 => (x"c0",x"4d",x"bf",x"c6"),
    13 => (x"74",x"1e",x"c0",x"4b"),
    14 => (x"87",x"c7",x"02",x"ab"),
    15 => (x"c0",x"48",x"a6",x"c4"),
    16 => (x"c4",x"87",x"c5",x"78"),
    17 => (x"78",x"c1",x"48",x"a6"),
    18 => (x"73",x"1e",x"66",x"c4"),
    19 => (x"87",x"df",x"ee",x"49"),
    20 => (x"e0",x"c0",x"86",x"c8"),
    21 => (x"87",x"ef",x"ef",x"49"),
    22 => (x"6a",x"4a",x"a5",x"c4"),
    23 => (x"87",x"f0",x"f0",x"49"),
    24 => (x"cb",x"87",x"c6",x"f1"),
    25 => (x"c8",x"83",x"c1",x"85"),
    26 => (x"ff",x"04",x"ab",x"b7"),
    27 => (x"26",x"26",x"87",x"c7"),
    28 => (x"26",x"4c",x"26",x"4d"),
    29 => (x"1e",x"4f",x"26",x"4b"),
    30 => (x"f0",x"c2",x"4a",x"71"),
    31 => (x"f0",x"c2",x"5a",x"ca"),
    32 => (x"78",x"c7",x"48",x"ca"),
    33 => (x"87",x"dd",x"fe",x"49"),
    34 => (x"73",x"1e",x"4f",x"26"),
    35 => (x"c0",x"4a",x"71",x"1e"),
    36 => (x"d3",x"03",x"aa",x"b7"),
    37 => (x"d1",x"d0",x"c2",x"87"),
    38 => (x"87",x"c4",x"05",x"bf"),
    39 => (x"87",x"c2",x"4b",x"c1"),
    40 => (x"d0",x"c2",x"4b",x"c0"),
    41 => (x"87",x"c4",x"5b",x"d5"),
    42 => (x"5a",x"d5",x"d0",x"c2"),
    43 => (x"bf",x"d1",x"d0",x"c2"),
    44 => (x"c1",x"9a",x"c1",x"4a"),
    45 => (x"ec",x"49",x"a2",x"c0"),
    46 => (x"48",x"fc",x"87",x"e8"),
    47 => (x"bf",x"d1",x"d0",x"c2"),
    48 => (x"87",x"ef",x"fe",x"78"),
    49 => (x"c4",x"4a",x"71",x"1e"),
    50 => (x"49",x"72",x"1e",x"66"),
    51 => (x"26",x"87",x"f5",x"e9"),
    52 => (x"c2",x"1e",x"4f",x"26"),
    53 => (x"49",x"bf",x"d1",x"d0"),
    54 => (x"c2",x"87",x"c8",x"e6"),
    55 => (x"e8",x"48",x"fe",x"ef"),
    56 => (x"ef",x"c2",x"78",x"bf"),
    57 => (x"bf",x"ec",x"48",x"fa"),
    58 => (x"fe",x"ef",x"c2",x"78"),
    59 => (x"cf",x"49",x"4a",x"bf"),
    60 => (x"b7",x"ca",x"99",x"ff"),
    61 => (x"71",x"48",x"72",x"2a"),
    62 => (x"c6",x"f0",x"c2",x"b0"),
    63 => (x"0e",x"4f",x"26",x"58"),
    64 => (x"5d",x"5c",x"5b",x"5e"),
    65 => (x"ff",x"4b",x"71",x"0e"),
    66 => (x"ef",x"c2",x"87",x"c8"),
    67 => (x"50",x"c0",x"48",x"f9"),
    68 => (x"f5",x"e5",x"49",x"73"),
    69 => (x"4c",x"49",x"70",x"87"),
    70 => (x"ee",x"cb",x"9c",x"c2"),
    71 => (x"87",x"f9",x"cb",x"49"),
    72 => (x"c2",x"4d",x"49",x"70"),
    73 => (x"bf",x"97",x"f9",x"ef"),
    74 => (x"87",x"e2",x"c1",x"05"),
    75 => (x"c2",x"49",x"66",x"d0"),
    76 => (x"99",x"bf",x"c2",x"f0"),
    77 => (x"d4",x"87",x"d6",x"05"),
    78 => (x"ef",x"c2",x"49",x"66"),
    79 => (x"05",x"99",x"bf",x"fa"),
    80 => (x"49",x"73",x"87",x"cb"),
    81 => (x"70",x"87",x"c3",x"e5"),
    82 => (x"c1",x"c1",x"02",x"98"),
    83 => (x"fe",x"4c",x"c1",x"87"),
    84 => (x"49",x"75",x"87",x"c0"),
    85 => (x"70",x"87",x"ce",x"cb"),
    86 => (x"87",x"c6",x"02",x"98"),
    87 => (x"48",x"f9",x"ef",x"c2"),
    88 => (x"ef",x"c2",x"50",x"c1"),
    89 => (x"05",x"bf",x"97",x"f9"),
    90 => (x"c2",x"87",x"e3",x"c0"),
    91 => (x"49",x"bf",x"c2",x"f0"),
    92 => (x"05",x"99",x"66",x"d0"),
    93 => (x"c2",x"87",x"d6",x"ff"),
    94 => (x"49",x"bf",x"fa",x"ef"),
    95 => (x"05",x"99",x"66",x"d4"),
    96 => (x"73",x"87",x"ca",x"ff"),
    97 => (x"87",x"c2",x"e4",x"49"),
    98 => (x"fe",x"05",x"98",x"70"),
    99 => (x"48",x"74",x"87",x"ff"),
   100 => (x"0e",x"87",x"dc",x"fb"),
   101 => (x"5d",x"5c",x"5b",x"5e"),
   102 => (x"c0",x"86",x"f4",x"0e"),
   103 => (x"bf",x"ec",x"4c",x"4d"),
   104 => (x"48",x"a6",x"c4",x"7e"),
   105 => (x"bf",x"c6",x"f0",x"c2"),
   106 => (x"c0",x"1e",x"c1",x"78"),
   107 => (x"fd",x"49",x"c7",x"1e"),
   108 => (x"86",x"c8",x"87",x"cd"),
   109 => (x"cd",x"02",x"98",x"70"),
   110 => (x"fb",x"49",x"ff",x"87"),
   111 => (x"da",x"c1",x"87",x"cc"),
   112 => (x"87",x"c6",x"e3",x"49"),
   113 => (x"ef",x"c2",x"4d",x"c1"),
   114 => (x"02",x"bf",x"97",x"f9"),
   115 => (x"de",x"d5",x"87",x"c3"),
   116 => (x"fe",x"ef",x"c2",x"87"),
   117 => (x"d0",x"c2",x"4b",x"bf"),
   118 => (x"c1",x"05",x"bf",x"d1"),
   119 => (x"a6",x"c4",x"87",x"da"),
   120 => (x"c0",x"c0",x"c2",x"48"),
   121 => (x"de",x"c2",x"78",x"c0"),
   122 => (x"97",x"6e",x"7e",x"c1"),
   123 => (x"48",x"6e",x"49",x"bf"),
   124 => (x"7e",x"70",x"80",x"c1"),
   125 => (x"87",x"d2",x"e2",x"71"),
   126 => (x"c3",x"02",x"98",x"70"),
   127 => (x"b3",x"66",x"c4",x"87"),
   128 => (x"c1",x"48",x"66",x"c4"),
   129 => (x"a6",x"c8",x"28",x"b7"),
   130 => (x"05",x"98",x"70",x"58"),
   131 => (x"c3",x"87",x"db",x"ff"),
   132 => (x"f5",x"e1",x"49",x"fd"),
   133 => (x"49",x"fa",x"c3",x"87"),
   134 => (x"73",x"87",x"ef",x"e1"),
   135 => (x"99",x"ff",x"cf",x"49"),
   136 => (x"49",x"c0",x"1e",x"71"),
   137 => (x"73",x"87",x"dd",x"fa"),
   138 => (x"29",x"b7",x"ca",x"49"),
   139 => (x"49",x"c1",x"1e",x"71"),
   140 => (x"c8",x"87",x"d1",x"fa"),
   141 => (x"87",x"ff",x"c5",x"86"),
   142 => (x"bf",x"c2",x"f0",x"c2"),
   143 => (x"dd",x"02",x"9b",x"4b"),
   144 => (x"cd",x"d0",x"c2",x"87"),
   145 => (x"dc",x"c7",x"49",x"bf"),
   146 => (x"05",x"98",x"70",x"87"),
   147 => (x"4b",x"c0",x"87",x"c4"),
   148 => (x"e0",x"c2",x"87",x"d2"),
   149 => (x"87",x"c1",x"c7",x"49"),
   150 => (x"58",x"d1",x"d0",x"c2"),
   151 => (x"d0",x"c2",x"87",x"c6"),
   152 => (x"78",x"c0",x"48",x"cd"),
   153 => (x"99",x"c2",x"49",x"73"),
   154 => (x"c3",x"87",x"cd",x"05"),
   155 => (x"d9",x"e0",x"49",x"eb"),
   156 => (x"c2",x"49",x"70",x"87"),
   157 => (x"87",x"c2",x"02",x"99"),
   158 => (x"49",x"73",x"4c",x"fb"),
   159 => (x"cd",x"05",x"99",x"c1"),
   160 => (x"49",x"f4",x"c3",x"87"),
   161 => (x"70",x"87",x"c3",x"e0"),
   162 => (x"02",x"99",x"c2",x"49"),
   163 => (x"4c",x"fa",x"87",x"c2"),
   164 => (x"99",x"c8",x"49",x"73"),
   165 => (x"c3",x"87",x"ce",x"05"),
   166 => (x"df",x"ff",x"49",x"f5"),
   167 => (x"49",x"70",x"87",x"ec"),
   168 => (x"d5",x"02",x"99",x"c2"),
   169 => (x"ca",x"f0",x"c2",x"87"),
   170 => (x"87",x"ca",x"02",x"bf"),
   171 => (x"c2",x"88",x"c1",x"48"),
   172 => (x"c0",x"58",x"ce",x"f0"),
   173 => (x"4c",x"ff",x"87",x"c2"),
   174 => (x"49",x"73",x"4d",x"c1"),
   175 => (x"ce",x"05",x"99",x"c4"),
   176 => (x"49",x"f2",x"c3",x"87"),
   177 => (x"87",x"c2",x"df",x"ff"),
   178 => (x"99",x"c2",x"49",x"70"),
   179 => (x"c2",x"87",x"dc",x"02"),
   180 => (x"7e",x"bf",x"ca",x"f0"),
   181 => (x"a8",x"b7",x"c7",x"48"),
   182 => (x"87",x"cb",x"c0",x"03"),
   183 => (x"80",x"c1",x"48",x"6e"),
   184 => (x"58",x"ce",x"f0",x"c2"),
   185 => (x"fe",x"87",x"c2",x"c0"),
   186 => (x"c3",x"4d",x"c1",x"4c"),
   187 => (x"de",x"ff",x"49",x"fd"),
   188 => (x"49",x"70",x"87",x"d8"),
   189 => (x"c0",x"02",x"99",x"c2"),
   190 => (x"f0",x"c2",x"87",x"d5"),
   191 => (x"c0",x"02",x"bf",x"ca"),
   192 => (x"f0",x"c2",x"87",x"c9"),
   193 => (x"78",x"c0",x"48",x"ca"),
   194 => (x"fd",x"87",x"c2",x"c0"),
   195 => (x"c3",x"4d",x"c1",x"4c"),
   196 => (x"dd",x"ff",x"49",x"fa"),
   197 => (x"49",x"70",x"87",x"f4"),
   198 => (x"c0",x"02",x"99",x"c2"),
   199 => (x"f0",x"c2",x"87",x"d9"),
   200 => (x"c7",x"48",x"bf",x"ca"),
   201 => (x"c0",x"03",x"a8",x"b7"),
   202 => (x"f0",x"c2",x"87",x"c9"),
   203 => (x"78",x"c7",x"48",x"ca"),
   204 => (x"fc",x"87",x"c2",x"c0"),
   205 => (x"c0",x"4d",x"c1",x"4c"),
   206 => (x"c0",x"03",x"ac",x"b7"),
   207 => (x"66",x"c4",x"87",x"d1"),
   208 => (x"82",x"d8",x"c1",x"4a"),
   209 => (x"c6",x"c0",x"02",x"6a"),
   210 => (x"74",x"4b",x"6a",x"87"),
   211 => (x"c0",x"0f",x"73",x"49"),
   212 => (x"1e",x"f0",x"c3",x"1e"),
   213 => (x"f6",x"49",x"da",x"c1"),
   214 => (x"86",x"c8",x"87",x"e5"),
   215 => (x"c0",x"02",x"98",x"70"),
   216 => (x"a6",x"c8",x"87",x"e2"),
   217 => (x"ca",x"f0",x"c2",x"48"),
   218 => (x"66",x"c8",x"78",x"bf"),
   219 => (x"c4",x"91",x"cb",x"49"),
   220 => (x"80",x"71",x"48",x"66"),
   221 => (x"bf",x"6e",x"7e",x"70"),
   222 => (x"87",x"c8",x"c0",x"02"),
   223 => (x"c8",x"4b",x"bf",x"6e"),
   224 => (x"0f",x"73",x"49",x"66"),
   225 => (x"c0",x"02",x"9d",x"75"),
   226 => (x"f0",x"c2",x"87",x"c8"),
   227 => (x"f2",x"49",x"bf",x"ca"),
   228 => (x"d0",x"c2",x"87",x"d3"),
   229 => (x"c0",x"02",x"bf",x"d5"),
   230 => (x"c2",x"49",x"87",x"dd"),
   231 => (x"98",x"70",x"87",x"c7"),
   232 => (x"87",x"d3",x"c0",x"02"),
   233 => (x"bf",x"ca",x"f0",x"c2"),
   234 => (x"87",x"f9",x"f1",x"49"),
   235 => (x"d9",x"f3",x"49",x"c0"),
   236 => (x"d5",x"d0",x"c2",x"87"),
   237 => (x"f4",x"78",x"c0",x"48"),
   238 => (x"87",x"f3",x"f2",x"8e"),
   239 => (x"5c",x"5b",x"5e",x"0e"),
   240 => (x"71",x"1e",x"0e",x"5d"),
   241 => (x"c6",x"f0",x"c2",x"4c"),
   242 => (x"cd",x"c1",x"49",x"bf"),
   243 => (x"d1",x"c1",x"4d",x"a1"),
   244 => (x"74",x"7e",x"69",x"81"),
   245 => (x"87",x"cf",x"02",x"9c"),
   246 => (x"74",x"4b",x"a5",x"c4"),
   247 => (x"c6",x"f0",x"c2",x"7b"),
   248 => (x"d2",x"f2",x"49",x"bf"),
   249 => (x"74",x"7b",x"6e",x"87"),
   250 => (x"87",x"c4",x"05",x"9c"),
   251 => (x"87",x"c2",x"4b",x"c0"),
   252 => (x"49",x"73",x"4b",x"c1"),
   253 => (x"d4",x"87",x"d3",x"f2"),
   254 => (x"87",x"c7",x"02",x"66"),
   255 => (x"70",x"87",x"da",x"49"),
   256 => (x"c0",x"87",x"c2",x"4a"),
   257 => (x"d9",x"d0",x"c2",x"4a"),
   258 => (x"e2",x"f1",x"26",x"5a"),
   259 => (x"00",x"00",x"00",x"87"),
   260 => (x"00",x"00",x"00",x"00"),
   261 => (x"00",x"00",x"00",x"00"),
   262 => (x"4a",x"71",x"1e",x"00"),
   263 => (x"49",x"bf",x"c8",x"ff"),
   264 => (x"26",x"48",x"a1",x"72"),
   265 => (x"c8",x"ff",x"1e",x"4f"),
   266 => (x"c0",x"fe",x"89",x"bf"),
   267 => (x"c0",x"c0",x"c0",x"c0"),
   268 => (x"87",x"c4",x"01",x"a9"),
   269 => (x"87",x"c2",x"4a",x"c0"),
   270 => (x"48",x"72",x"4a",x"c1"),
   271 => (x"5e",x"0e",x"4f",x"26"),
   272 => (x"0e",x"5d",x"5c",x"5b"),
   273 => (x"d4",x"ff",x"4b",x"71"),
   274 => (x"48",x"66",x"d0",x"4c"),
   275 => (x"49",x"d6",x"78",x"c0"),
   276 => (x"87",x"f6",x"da",x"ff"),
   277 => (x"6c",x"7c",x"ff",x"c3"),
   278 => (x"99",x"ff",x"c3",x"49"),
   279 => (x"c3",x"49",x"4d",x"71"),
   280 => (x"e0",x"c1",x"99",x"f0"),
   281 => (x"87",x"cb",x"05",x"a9"),
   282 => (x"6c",x"7c",x"ff",x"c3"),
   283 => (x"d0",x"98",x"c3",x"48"),
   284 => (x"c3",x"78",x"08",x"66"),
   285 => (x"4a",x"6c",x"7c",x"ff"),
   286 => (x"c3",x"31",x"c8",x"49"),
   287 => (x"4a",x"6c",x"7c",x"ff"),
   288 => (x"49",x"72",x"b2",x"71"),
   289 => (x"ff",x"c3",x"31",x"c8"),
   290 => (x"71",x"4a",x"6c",x"7c"),
   291 => (x"c8",x"49",x"72",x"b2"),
   292 => (x"7c",x"ff",x"c3",x"31"),
   293 => (x"b2",x"71",x"4a",x"6c"),
   294 => (x"c0",x"48",x"d0",x"ff"),
   295 => (x"9b",x"73",x"78",x"e0"),
   296 => (x"72",x"87",x"c2",x"02"),
   297 => (x"26",x"48",x"75",x"7b"),
   298 => (x"26",x"4c",x"26",x"4d"),
   299 => (x"1e",x"4f",x"26",x"4b"),
   300 => (x"5e",x"0e",x"4f",x"26"),
   301 => (x"f8",x"0e",x"5c",x"5b"),
   302 => (x"c8",x"1e",x"76",x"86"),
   303 => (x"fd",x"fd",x"49",x"a6"),
   304 => (x"70",x"86",x"c4",x"87"),
   305 => (x"c0",x"48",x"6e",x"4b"),
   306 => (x"f0",x"c2",x"01",x"a8"),
   307 => (x"c3",x"4a",x"73",x"87"),
   308 => (x"d0",x"c1",x"9a",x"f0"),
   309 => (x"87",x"c7",x"02",x"aa"),
   310 => (x"05",x"aa",x"e0",x"c1"),
   311 => (x"73",x"87",x"de",x"c2"),
   312 => (x"02",x"99",x"c8",x"49"),
   313 => (x"c6",x"ff",x"87",x"c3"),
   314 => (x"c3",x"4c",x"73",x"87"),
   315 => (x"05",x"ac",x"c2",x"9c"),
   316 => (x"c4",x"87",x"c2",x"c1"),
   317 => (x"31",x"c9",x"49",x"66"),
   318 => (x"66",x"c4",x"1e",x"71"),
   319 => (x"c2",x"92",x"d4",x"4a"),
   320 => (x"72",x"49",x"ce",x"f0"),
   321 => (x"e6",x"d2",x"fe",x"81"),
   322 => (x"ff",x"49",x"d8",x"87"),
   323 => (x"c8",x"87",x"fb",x"d7"),
   324 => (x"de",x"c2",x"1e",x"c0"),
   325 => (x"ef",x"fd",x"49",x"fe"),
   326 => (x"d0",x"ff",x"87",x"c1"),
   327 => (x"78",x"e0",x"c0",x"48"),
   328 => (x"1e",x"fe",x"de",x"c2"),
   329 => (x"d4",x"4a",x"66",x"cc"),
   330 => (x"ce",x"f0",x"c2",x"92"),
   331 => (x"fe",x"81",x"72",x"49"),
   332 => (x"cc",x"87",x"f9",x"d0"),
   333 => (x"05",x"ac",x"c1",x"86"),
   334 => (x"c4",x"87",x"c2",x"c1"),
   335 => (x"31",x"c9",x"49",x"66"),
   336 => (x"66",x"c4",x"1e",x"71"),
   337 => (x"c2",x"92",x"d4",x"4a"),
   338 => (x"72",x"49",x"ce",x"f0"),
   339 => (x"de",x"d1",x"fe",x"81"),
   340 => (x"fe",x"de",x"c2",x"87"),
   341 => (x"4a",x"66",x"c8",x"1e"),
   342 => (x"f0",x"c2",x"92",x"d4"),
   343 => (x"81",x"72",x"49",x"ce"),
   344 => (x"87",x"c5",x"cf",x"fe"),
   345 => (x"d6",x"ff",x"49",x"d7"),
   346 => (x"c0",x"c8",x"87",x"e0"),
   347 => (x"fe",x"de",x"c2",x"1e"),
   348 => (x"d0",x"ed",x"fd",x"49"),
   349 => (x"ff",x"86",x"cc",x"87"),
   350 => (x"e0",x"c0",x"48",x"d0"),
   351 => (x"fc",x"8e",x"f8",x"78"),
   352 => (x"5e",x"0e",x"87",x"e7"),
   353 => (x"0e",x"5d",x"5c",x"5b"),
   354 => (x"ff",x"4d",x"71",x"1e"),
   355 => (x"66",x"d4",x"4c",x"d4"),
   356 => (x"b7",x"c3",x"48",x"7e"),
   357 => (x"87",x"c5",x"06",x"a8"),
   358 => (x"e2",x"c1",x"48",x"c0"),
   359 => (x"fe",x"49",x"75",x"87"),
   360 => (x"75",x"87",x"dd",x"df"),
   361 => (x"4b",x"66",x"c4",x"1e"),
   362 => (x"f0",x"c2",x"93",x"d4"),
   363 => (x"49",x"73",x"83",x"ce"),
   364 => (x"87",x"d9",x"ca",x"fe"),
   365 => (x"4b",x"6b",x"83",x"c8"),
   366 => (x"c8",x"48",x"d0",x"ff"),
   367 => (x"7c",x"dd",x"78",x"e1"),
   368 => (x"ff",x"c3",x"49",x"73"),
   369 => (x"73",x"7c",x"71",x"99"),
   370 => (x"29",x"b7",x"c8",x"49"),
   371 => (x"71",x"99",x"ff",x"c3"),
   372 => (x"d0",x"49",x"73",x"7c"),
   373 => (x"ff",x"c3",x"29",x"b7"),
   374 => (x"73",x"7c",x"71",x"99"),
   375 => (x"29",x"b7",x"d8",x"49"),
   376 => (x"7c",x"c0",x"7c",x"71"),
   377 => (x"7c",x"7c",x"7c",x"7c"),
   378 => (x"7c",x"7c",x"7c",x"7c"),
   379 => (x"c0",x"7c",x"7c",x"7c"),
   380 => (x"66",x"c4",x"78",x"e0"),
   381 => (x"ff",x"49",x"dc",x"1e"),
   382 => (x"c8",x"87",x"f4",x"d4"),
   383 => (x"26",x"48",x"73",x"86"),
   384 => (x"0e",x"87",x"e4",x"fa"),
   385 => (x"5d",x"5c",x"5b",x"5e"),
   386 => (x"7e",x"71",x"1e",x"0e"),
   387 => (x"6e",x"4b",x"d4",x"ff"),
   388 => (x"e2",x"f0",x"c2",x"1e"),
   389 => (x"f4",x"c8",x"fe",x"49"),
   390 => (x"70",x"86",x"c4",x"87"),
   391 => (x"c3",x"02",x"9d",x"4d"),
   392 => (x"f0",x"c2",x"87",x"c3"),
   393 => (x"6e",x"4c",x"bf",x"ea"),
   394 => (x"d3",x"dd",x"fe",x"49"),
   395 => (x"48",x"d0",x"ff",x"87"),
   396 => (x"c1",x"78",x"c5",x"c8"),
   397 => (x"4a",x"c0",x"7b",x"d6"),
   398 => (x"82",x"c1",x"7b",x"15"),
   399 => (x"aa",x"b7",x"e0",x"c0"),
   400 => (x"ff",x"87",x"f5",x"04"),
   401 => (x"78",x"c4",x"48",x"d0"),
   402 => (x"c1",x"78",x"c5",x"c8"),
   403 => (x"7b",x"c1",x"7b",x"d3"),
   404 => (x"9c",x"74",x"78",x"c4"),
   405 => (x"87",x"fc",x"c1",x"02"),
   406 => (x"7e",x"fe",x"de",x"c2"),
   407 => (x"8c",x"4d",x"c0",x"c8"),
   408 => (x"03",x"ac",x"b7",x"c0"),
   409 => (x"c0",x"c8",x"87",x"c6"),
   410 => (x"4c",x"c0",x"4d",x"a4"),
   411 => (x"97",x"ef",x"eb",x"c2"),
   412 => (x"99",x"d0",x"49",x"bf"),
   413 => (x"c0",x"87",x"d2",x"02"),
   414 => (x"e2",x"f0",x"c2",x"1e"),
   415 => (x"e8",x"ca",x"fe",x"49"),
   416 => (x"70",x"86",x"c4",x"87"),
   417 => (x"ef",x"c0",x"4a",x"49"),
   418 => (x"fe",x"de",x"c2",x"87"),
   419 => (x"e2",x"f0",x"c2",x"1e"),
   420 => (x"d4",x"ca",x"fe",x"49"),
   421 => (x"70",x"86",x"c4",x"87"),
   422 => (x"d0",x"ff",x"4a",x"49"),
   423 => (x"78",x"c5",x"c8",x"48"),
   424 => (x"6e",x"7b",x"d4",x"c1"),
   425 => (x"6e",x"7b",x"bf",x"97"),
   426 => (x"70",x"80",x"c1",x"48"),
   427 => (x"05",x"8d",x"c1",x"7e"),
   428 => (x"ff",x"87",x"f0",x"ff"),
   429 => (x"78",x"c4",x"48",x"d0"),
   430 => (x"c5",x"05",x"9a",x"72"),
   431 => (x"c0",x"48",x"c0",x"87"),
   432 => (x"1e",x"c1",x"87",x"e5"),
   433 => (x"49",x"e2",x"f0",x"c2"),
   434 => (x"87",x"fc",x"c7",x"fe"),
   435 => (x"9c",x"74",x"86",x"c4"),
   436 => (x"87",x"c4",x"fe",x"05"),
   437 => (x"c8",x"48",x"d0",x"ff"),
   438 => (x"d3",x"c1",x"78",x"c5"),
   439 => (x"c4",x"7b",x"c0",x"7b"),
   440 => (x"c2",x"48",x"c1",x"78"),
   441 => (x"26",x"48",x"c0",x"87"),
   442 => (x"4c",x"26",x"4d",x"26"),
   443 => (x"4f",x"26",x"4b",x"26"),
   444 => (x"5c",x"5b",x"5e",x"0e"),
   445 => (x"cc",x"4b",x"71",x"0e"),
   446 => (x"87",x"d8",x"02",x"66"),
   447 => (x"8c",x"f0",x"c0",x"4c"),
   448 => (x"74",x"87",x"d8",x"02"),
   449 => (x"02",x"8a",x"c1",x"4a"),
   450 => (x"02",x"8a",x"87",x"d1"),
   451 => (x"02",x"8a",x"87",x"cd"),
   452 => (x"87",x"d7",x"87",x"c9"),
   453 => (x"ea",x"fb",x"49",x"73"),
   454 => (x"74",x"87",x"d0",x"87"),
   455 => (x"f9",x"49",x"c0",x"1e"),
   456 => (x"1e",x"74",x"87",x"e0"),
   457 => (x"d9",x"f9",x"49",x"73"),
   458 => (x"fe",x"86",x"c8",x"87"),
   459 => (x"1e",x"00",x"87",x"fc"),
   460 => (x"bf",x"fd",x"dd",x"c2"),
   461 => (x"c2",x"b9",x"c1",x"49"),
   462 => (x"ff",x"59",x"c1",x"de"),
   463 => (x"ff",x"c3",x"48",x"d4"),
   464 => (x"48",x"d0",x"ff",x"78"),
   465 => (x"ff",x"78",x"e1",x"c8"),
   466 => (x"78",x"c1",x"48",x"d4"),
   467 => (x"78",x"71",x"31",x"c4"),
   468 => (x"c0",x"48",x"d0",x"ff"),
   469 => (x"4f",x"26",x"78",x"e0"),
   470 => (x"f1",x"dd",x"c2",x"1e"),
   471 => (x"e2",x"f0",x"c2",x"1e"),
   472 => (x"e8",x"c3",x"fe",x"49"),
   473 => (x"70",x"86",x"c4",x"87"),
   474 => (x"87",x"c3",x"02",x"98"),
   475 => (x"26",x"87",x"c0",x"ff"),
   476 => (x"4b",x"35",x"31",x"4f"),
   477 => (x"20",x"20",x"5a",x"48"),
   478 => (x"47",x"46",x"43",x"20"),
   479 => (x"00",x"00",x"00",x"00"),
   480 => (x"58",x"9f",x"1a",x"00"),
   481 => (x"1d",x"14",x"11",x"12"),
   482 => (x"4a",x"23",x"1c",x"1b"),
   483 => (x"91",x"59",x"5a",x"a7"),
   484 => (x"eb",x"f2",x"f5",x"94"),
   485 => (x"eb",x"f2",x"f5",x"f4"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;
