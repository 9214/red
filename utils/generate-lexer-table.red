Red [
	Title:   "Generates low-level lexer table"
	Author:  "Nenad Rakocevic"
	File: 	 %generate-lexer-tables.r
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Red Foundation. All rights reserved."
	License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
	Note: {
		Outputs: %runtime/lexer-transitions.reds
	}
]

context [
	states: [
	;-- State ------------- Predicted type ----
		S_START				TYPE_VALUE			;-- 0
		S_LINE_CMT			TYPE_VALUE			;-- 1
		S_LINE_STR			TYPE_STRING			;-- 2
		S_SKIP_STR			TYPE_STRING			;-- 3
		S_M_STRING			TYPE_STRING			;-- 4
		S_SKIP_MSTR			TYPE_STRING			;-- 5
		S_FILE_1ST			TYPE_FILE			;-- 6
		S_FILE				TYPE_FILE			;-- 7
		S_FILE_HEX1			TYPE_FILE			;-- 8
		S_FILE_HEX2			TYPE_FILE			;-- 9
		S_FILE_STR			TYPE_FILE			;-- 10
		S_SLASH				TYPE_PATH			;-- 11
		S_SHARP				TYPE_ISSUE			;-- 12
		S_BINARY			TYPE_BINARY			;-- 13
		S_LINE_CMT2			TYPE_VALUE			;-- 14
		S_CHAR				TYPE_CHAR			;-- 15
		S_SKIP_CHAR			TYPE_CHAR			;-- 16
		S_CONSTRUCT			TYPE_VALUE			;-- 17
		S_ISSUE				TYPE_ISSUE			;-- 18
		S_NUMBER			TYPE_INTEGER		;-- 19
		S_DOTNUM			TYPE_FLOAT			;-- 20
		S_DECIMAL			TYPE_FLOAT			;-- 21
		S_DECX				TYPE_FLOAT			;-- 22
		S_DEC_SPECIAL		TYPE_FLOAT			;-- 23
		S_TUPLE				TYPE_TUPLE			;-- 24
		S_DATE				TYPE_DATE			;-- 25
		S_TIME_1ST			TYPE_TIME			;-- 26
		S_TIME				TYPE_TIME			;-- 27
		S_PAIR_1ST			TYPE_PAIR			;-- 28
		S_PAIR				TYPE_PAIR			;-- 29
		S_MONEY_1ST			TYPE_MONEY			;-- 30
		S_MONEY				TYPE_MONEY			;-- 31
		S_MONEY_DEC			TYPE_MONEY			;-- 32
		S_HEX				TYPE_INTEGER		;-- 33
		S_LESSER			TYPE_TAG			;-- 34
		S_TAG				TYPE_TAG			;-- 35
		S_TAG_STR			TYPE_TAG			;-- 36
		S_SKIP_STR2			TYPE_TAG			;-- 37
		S_TAG_STR2			TYPE_TAG			;-- 38
		S_SKIP_STR3			TYPE_TAG			;-- 39
		S_SIGN				TYPE_WORD			;-- 40
		S_DOTWORD			TYPE_WORD			;-- 41
		S_DOTDEC			TYPE_FLOAT			;-- 42
		S_WORD_1ST			TYPE_WORD			;--	43
		S_WORD				TYPE_WORD			;-- 44
		S_WORDSET			TYPE_SET_WORD		;-- 45
		S_URL				TYPE_URL			;-- 46
		S_EMAIL				TYPE_EMAIL			;-- 47
		S_PATH				TYPE_PATH			;-- 48
		S_PATH_NUM			TYPE_INTEGER		;--	49
		S_PATH_W1ST			TYPE_WORD			;-- 50
		S_PATH_WORD			TYPE_WORD			;-- 51
		S_PATH_SHARP		TYPE_ISSUE			;--	52
		S_PATH_SIGN			TYPE_WORD			;--	53
		--EXIT_STATES--		-					;-- 54
		T_EOF				-					;-- 55
		T_ERROR				-					;-- 56
		T_BLK_OP			-					;-- 57
		T_BLK_CL			-					;-- 58
		T_PAR_OP			-					;-- 59
		T_PAR_CL			-					;-- 60
		T_STRING			-					;-- 61
		T_MSTR_OP			-					;-- 62
		T_MSTR_CL			-					;-- 63
		T_WORD				-					;-- 64
		T_FILE				-					;-- 65
		T_REFINE			-					;-- 66
		T_BINARY			-					;-- 67
		T_CHAR				-					;-- 68
		T_MAP_OP			-					;-- 69
		T_CONS_MK			-					;-- 70
		T_ISSUE				-					;-- 71
		T_PERCENT			-					;-- 72
		T_INTEGER			-					;-- 73
		T_FLOAT				-					;-- 74
		T_FLOAT_SP			-					;-- 75
		T_TUPLE				-					;-- 76
		T_DATE				-					;-- 77
		T_PAIR				-					;-- 78
		T_TIME				-					;-- 79
		T_MONEY				-					;-- 80
		T_TAG				-					;-- 81
		T_URL				-					;-- 82
		T_EMAIL				-					;-- 83
		T_PATH				-					;-- 84
		T_HEX				-					;-- 85
		T_CMT				-					;-- 86
	]

	CSV-table: %../docs/lexer/lexer-FSM.csv
	;-- Read states from CSV file
	csv: read CSV-table

	;-- Determine CSV separator
	sep: [#";" 0 #"," 0]
	parse csv [some [#";" (sep/2: sep/2 + 1) | #"," (sep/4: sep/4 + 1) | skip]]
	sort/skip/all/compare sep 2 func [a b][a/2 > b/2]

	;-- Decode CSV
	matrix: load-csv/with read CSV-table first sep

	;-- Generate the lexer table content
	table: make binary! 2000
	
	foreach line next matrix [
		out: make block! 50	
		foreach s next line [
			either pos: find/skip states to-word s  2[
				append out (index? pos) + 1 / 2 - 1
			][
				do make error! form reduce ["Error: state" s "not found"]
			]
		]
		append/only table out
	]
	
	;-- Generate the prev-table content
	prev-table: make binary! 2000
	types: load %../runtime/macros.reds
	types: select types 'datatypes!
	
	foreach [s t] states [
		if s = '--EXIT_STATES-- [break]
		append prev-table (index? find types t) - 1
	]
	
	template: compose/deep [Red/System [
		Note: "Auto-generated lexical scanner transitions table"
	]
	
	#enum lex-states! [
		(extract states 2)
	]
	
	prev-table: (prev-table)
		
	transitions: (table)
	]

	write %../runtime/lexer-transitions.reds mold/only template
]
()