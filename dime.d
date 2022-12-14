
/*
	Malayalam IME tool - Dime. 
	Language : D
	Started Date : 28-June-2022
	Completed Date : 28-September-2022 (1st working version)
	
*/

import wings ;
import core.sys.windows.windows;
import std.stdio : log = writeln;
import std.algorithm;
import std.stdio;
import std.format;
import std.datetime.stopwatch ;

mixin EnableWindowsSubSystem ;
// Eng Letters and Mal letters
	enum : DWORD {ak = 65, bk, ck, dk, ek, fk, gk, hk, ik, jk, kk, lk, mk, nk, ok, pk, qk, rk, sk, tk, 
				uk, vk, wk, xk, yk, zk, sck = 186, usk = 189, bsk = 8} // String all virtual key codes.

	enum : char {ac = 97, bc, cc, dc, ec, fc, gc, hc, ic, jc, kc, lc, mc, nc, oc, pc, qc, rc, sc, tc, 
				uc, vc, wc, xc, yc, zc, scc = 59, bsc = 8, hyp = 45 } // Storing all needed small letter characters

	enum : char {	Ac = 65, Bc, Cc, Dc, Ec, Fc, Gc, Hc, Ic, Jc, Kc, Lc, Mc, Nc, Oc, Pc, Qc, Rc, Sc, Tc, 
					Uc, Vc, Wc, Xc, Yc, Zc, SCc = 58, BSc = 8, Uscore = 95} // Storing all needed BIG letter characters
  
	enum ushort zwnj = 0x200C;
	enum ushort uHyp = 0x002D;
	enum ushort kau = 0x0D57;
	enum ushort anu = 0x0D02;
	enum ushort visa = 0x0D03;
	enum ushort chdk = 0x0D4D;
	enum trueLresult = cast(LRESULT) true;
	enum falseLresult = cast(LRESULT) false;	
	enum uint inpSize = INPUT.sizeof; /// Size of INPUT struct. This is a global variable.
	enum short msb = 0b_10000000_0000000;
	enum string fmt = "Match No -[%s]  %s - [eng - [%-(%s, %)],   Mal - [%-(0x%X, %)],  context - [%-(%s, %)],  bs : %s";

	//NOTE:: Adding elements to any of these dics, you will need to increase the array size for keyList.
	
	enum char[DWORD] vkc_char_dic = [	ak : ac, bk : bc, ck : cc, dk : dc, ek : ec, fk : fc, gk : gc, hk : hc, 
										ik : ic, jk : jc, kk : kc, lk : lc, mk : mc, nk : nc, ok : oc, pk : pc, 
										qk : qc, rk : rc, sk : sc, tk : tc, uk : uc, vk : vc, wk : wc, xk : xc, 
										yk : yc, zk : zc, sck : scc, bsk : bsc, usk : hyp]; // A dictionary to find lower case char 

	enum char[DWORD] VKC_CHAR_DIC = [	ak : Ac, bk : Bc, ck : Cc, dk : Dc, ek : Ec, fk : Fc, gk : Gc, hk : Hc, 	
										ik : Ic, jk : Jc, kk : Kc, lk : Lc, mk : Mc, nk : Nc, ok : Oc, pk : Pc, 
										qk : Qc, rk : Rc, sk : Sc, tk : Tc, uk : Uc, vk : Vc, wk : Wc, xk : Xc, 
										yk : Yc, zk : Zc, sck : SCc, bsk : BSc, usk : Uscore]; // A dictionary to find upper case char

	//enum char usk = 95;

	
	enum : ushort { ??? = 0x0D05, ???, ???, ???, ???, ???, ???, ??? = 0x0D0E, ???, ??? }
	
	enum : ushort { ??? = 0x0D12, ???, ???, ???, ???, ???, ???, ???, ???, ???, ???, ???, ???, ???, 
					O, ???, ???, ???, ???, ???, ???, ???, ???,  ??? = 0x0D2A, ???, ???, ???, ???, ???,
					???, ???, ???, ???, ???, ???, ???, ???, ???, ??? }
		
	enum : ushort { ?????? = 0x0D3E, ??????, ??????, ??????, ??????, ??????, ?????? = 0x0D46, ??????, ??????}	
	enum : ushort { ?????? = 0x0D4A, ?????? }
	enum : ushort { chill_N = 0x0D7A, chill_n, chill_r, chill_l, chill_L }	
	
	enum ushort[][char] all_vowel_chars = [ac : [???, ???, 0, ??????, ??????], ec : [???, ???, 0, ??????, ??????], ic : [???, ???, 0, ??????, ??????], 
											oc : [???, ???, 0, ??????, ??????], uc : [???, ???, 0, ??????, ??????], Ac : [???, 0, 1, ??????, 0], 
											Ec : [???, 0, 1, ??????, 0], Ic : [???, 0, 1, ??????, 0], Oc : [???, 0, 1, ??????, 0], 
											Uc : [???, 0, 1, ??????, 0]];	

	//---------------------Key Data dictionaries-(Change here for individual key-letter match)---------------------------------

	enum ushort[][char] dbl_kp_consos = [ 	bc : [???, chdk], cc : [???, chdk], dc : [???, chdk], gc : [???, chdk],  
											jc : [???, chdk], kc : [???, chdk], 
											pc : [???, chdk],   sc : [???, chdk], tc : [???, chdk], vc : [???, chdk], yc : [???, chdk], 
											zc : [???, chdk], Dc : [???, chdk] ];

	enum ushort[][char] sin_kp_consos = [	fc : [???, chdk], hc : [???, chdk], qc : [O, chdk], xc : [???, chdk, ???, chdk], 
											Bc : [???, chdk], Cc : [???, chdk, ???, chdk], Fc : [???, chdk], Gc : [???, chdk], 
											Hc : [???, chdk], Jc : [???, chdk, ???, chdk], Kc : [???, chdk, ???, chdk], 
											Mc : [???, chdk, ???, chdk], Pc : [???, chdk, ???, chdk], Qc : [???, chdk, ???, chdk], 
											Rc : [???, chdk], Sc : [???, chdk], Tc : [???, chdk, ???, chdk], Vc : [???, chdk, ???, chdk], 
											wc : [chdk, ???], Wc : [chdk, ???], Xc : [visa], Yc : [???, chdk, ???, chdk], 
											Zc : [???, chdk, ???, chdk] ];

	enum ushort[][char] whole_vyanjans = [	fc : [???, chdk], hc : [???, chdk], qc : [O, chdk], xc : [???, chdk, ???, chdk], 
											Bc : [???, chdk], Cc : [???, chdk, ???, chdk], Fc : [???, chdk], Gc : [???, chdk], 
											Hc : [???, chdk], Jc : [???, chdk, ???, chdk], Kc : [???, chdk, ???, chdk], 
											Mc : [???, chdk, ???, chdk], Pc : [???, chdk, ???, chdk], Qc : [???, chdk, ???, chdk], 
											Rc : [???, chdk], Sc : [???, chdk], Tc : [???, chdk, ???, chdk], Vc : [???, chdk, ???, chdk], 
											wc : [chdk, ???], Wc : [chdk, ???], Xc : [visa], Yc : [???, chdk, ???, chdk], 
											Zc : [???, chdk, ???, chdk], bc : [???, chdk], cc : [???, chdk], dc : [???, chdk], gc : [???, chdk],  
											jc : [???, chdk], kc : [???, chdk], pc : [???, chdk],   sc : [???, chdk], tc : [???, chdk], 
											vc : [???, chdk], yc : [???, chdk], zc : [???, chdk], Dc : [???, chdk] ];

	
	enum char[] chill_chars_arr = [lc, mc, nc, rc, Lc, Nc, Rc];
	enum ushort[] chill_bases_arr = [???, ???, ???, ???, ???, ???, ???];
	enum ushort[] chill_codes_arr = [chill_l, anu, chill_n, chill_r, chill_L, chill_N, ???];
	enum ushort[][] chill_doubles_arr = [[???, chdk, ???, chdk], [???, chdk, ???, chdk], [???, chdk, ???, chdk], [???, chdk],
										 [???, chdk, ???, chdk], [???, chdk, ???, chdk], [???]];
	enum char[] signable_consos = [bc, cc, dc, fc, gc, hc, jc, kc, lc, mc, nc, pc, qc, rc, sc, tc, vc, wc, xc, yc, zc, 
									Bc, Cc, Dc, Fc, Gc, Jc, Kc, Lc, Mc, Nc, Pc, Rc, Sc, Tc, Vc, Wc, Yc, Zc ];
	
// End of chars and ushort declarations.

// Required types and functions	
	enum KeyKind {system, vowel, single, doubler, chill }

	struct KeyData {
		char echar; /// english char for this key.
    	ushort[] spCode; /// Malayalam codes for single key press.
		ushort[] dpCode; /// Malayalam codes for double key press.
		KeyKind kind; /// key kind of this key [system, smallvow, bigvow, single, doubler, chill]		
		union {
			Vowel vow;
			Letter let;
			ushort base;
		}		
	}

	struct Vowel  {
		bool isBigger;
		ushort smallSign;
		ushort bigSign;		
	}	
		
	struct Letter {
		bool isDoubler;
		bool isJoiner;
		bool isHtrans;
	}

	struct MatchCopy {
		MatchData match;
		ushort[] ccmCode; /// Current char's malayalam code
		bool bFound; /// If a match is found or not		
	}

	void createKeyData(char ech, ushort mcod1, ushort mcod2) { // for system keys
		KeyData kd;
		kd.echar = ech;
		kd.spCode ~= mcod1;
		kd.dpCode ~= mcod2;
		kd.kind = KeyKind.system;
		keyList[knum] = kd; 
		++knum;
	}

	void createKeyData(char ech, ushort[] data ) { // for vowels
		KeyData kd;
		kd.echar = ech;
		kd.spCode ~= data[0];
		if (data[2] == 0) { // it's small vowel.
			kd.dpCode ~= data[1]; // [???, ???, 0, ??????, ??????], [???, 0, 1, ??????, 0]
			kd.vow.smallSign = data[3];
			kd.vow.bigSign = data[4];
			kd.vow.isBigger = false;
		} else {			
			kd.vow.bigSign = data[3];
			kd.vow.isBigger = true;
		}
		kd.kind = KeyKind.vowel;
		keyList[knum] = kd; 
		++knum;
	}

	void createKeyData(char ech, ushort mch, ushort[] cdbls, ushort mcb) { // for chills
		KeyData kd;
		kd.echar = ech;		
		kd.spCode ~= mch;
		if (ech == Rc) {kd.spCode = kd.spCode ~ chdk; }
		kd.dpCode = cdbls;
		kd.base = mcb;
		kd.kind = KeyKind.chill;
		keyList[knum] = kd; 
		++knum;
		//if (ech == Rc) writefln("Rc's kd.dpCode - %-(0x%X %)", kd.dpCode);
	}
	
	void createKeyData(char ech, ushort[] mch1, ushort[] mch2) { // for letters
		KeyData kd;
		kd.echar = ech;
		kd.spCode = mch1;
		if (mch2 != null) { 
			kd.dpCode = mch2;
			kd.kind = KeyKind.doubler;
		} 
		else {
			kd.kind = KeyKind.single;
		}		
		keyList[knum] = kd; 
		++knum;
	}

	struct MatchData {
		char[] echars;
		ushort[] spCode;
		size_t bspaces;
		int idNum ;

		string toStr() {
			string es = format("%-(%s, %)", echars);
			wchar[] w;
			foreach (u; spCode) w ~= cast(wchar) u;
			string ms = format("%-(%s%)", w);
			return format("No : [%s] %s  ---  %s\n", idNum, es, ms);
		}
	}
	
	void addMatch(char[] ecs, ushort[] mcs, size_t bs, int matchId) {		
		MatchData md = MatchData(ecs, mcs, bs, matchId);
		matchList ~= md;
		if (ecs.length > maxRuleLength) maxRuleLength = ecs.length;
	}

	void addSignMatchesForLetter(char[] echars, ushort[] mLetter) {
		foreach (ch, mcod; sm_signs) {
			if (ch == ac) {
				addMatch(echars ~ ch, null, 1, __LINE__) ; // Single
				addMatch(echars ~ [ch, ch], [mcod], 0, __LINE__); // double
			} else {
				addMatch(echars ~ ch, [mcod], 1, __LINE__); // Single				 
			}
		}

		foreach (ch, mcod; bgs_special) {
			if (ch != ac) {					
				addMatch(echars ~ [ch, ch], [mcod], 1, __LINE__); // Double
			}
		}

		foreach (ch, mcod; bg_signs) {
			addMatch(echars ~ ch, [mcod], 1, __LINE__);
		}

		foreach (ch, mcod; chdk_signs) {
			addMatch(echars ~ ch, [mcod], 1, __LINE__);
		}
	}

// End of types and functions

// My own keymap rules	
	void generateMatches() {	

		foreach (kd; keyList) {
			switch (kd.kind) {
				case KeyKind.vowel:						
					 // In this dic - [1, ???, ??????, ???, ??????] & [2, ???, ??????] 
					addMatch([kd.echar], kd.spCode, 0, __LINE__);
					if (!kd.vow.isBigger) addMatch([kd.echar, kd.echar], kd.dpCode, 1, __LINE__); // double key press
					if (kd.echar == ac) {
						addMatch([ac, ic], [???], 1, __LINE__);
						addMatch([ac, uc], [???], 1, __LINE__);
					}
					break;

				case KeyKind.chill :					
					createChillMatches(kd);	
					createDoublerMatches(kd);												
					break;

				case KeyKind.single:
					createConsosMatches(kd);
					break;

				case KeyKind.doubler:
					createConsosMatches(kd);
					createDoublerMatches(kd);					
					break;
				default : break;
			}
		}

		createDoubleSignMatches();	// pressing double vowel signs after a letter		
		addMatch([scc, scc], [scc], 1, __LINE__); // Semicolon on dual press
		addMatch([Xc], [???, chdk, ???, chdk], 0, __LINE__) ; //Extra option for THa 	
		addMatch([dc, dc, hc], [???, chdk], 3, __LINE__); //  h transforming letters

		ushort[char] htransList = [cc : ???, bc : ???, dc : ???, Dc : ???, gc : ???, jc : ???, kc : ???, sc : ???, tc : ???, zc : ???];
		foreach (ch, uc; htransList) addMatch([ch, hc], [uc, chdk], 2, __LINE__);

		// m special
		addMatch([mc, pc], [???, chdk, ???, chdk], 1, __LINE__);

		// n Special matches 
		ushort[][char] nCombos = [	cc : [???, chdk, ???], dc : [???, chdk, ???], gc : [???, chdk, ???], jc : [???], 
									Jc : [???, chdk, ???], kc : [???, chdk, ???], mc : [???, chdk, ???], tc : [???, chdk, ???]];
		foreach (c, arr; nCombos) { addMatch([nc, c], arr ~ chdk, 1, __LINE__); }

		addMatch([nc, dc, hc], [???, chdk], 2, __LINE__); // ????????? // Start here
		addMatch([nc, tc, hc], [???, chdk], 2, __LINE__); // ?????????
		addMatch([nc, tc, hc, hc], [???, chdk], 2, __LINE__); // ?????????
		addMatch([nc, nc, gc], [???, chdk], 4, __LINE__); // Special case for ?????? 
		addMatch([nc, jc, jc], [???, chdk], 0, __LINE__); // Special case for  
		addMatch([Nc, mc], [???, chdk, ???, chdk], 1, __LINE__); // Special case for
		addMatch([Nc, Tc], [???, chdk, ???, chdk], 1, __LINE__); // Special case for
		addMatch([Nc, tc], [???, chdk, ???, chdk], 1, __LINE__); // Special case for
		addMatch([jc, nc, jc], [???, chdk], 1, __LINE__); // Special case for  
		

		// Special mixed letters
		addSignMatchesForLetter([nc, mc], [chill_n, ???]);
		addSignMatchesForLetter([Nc, mc], [???, chdk, ???]);

		ushort[][char] signsArr = [	ec : [??????, ??????], ic : [??????, ??????], oc : [??????, ??????], uc : [??????, ??????], 
									Ac : [??????], Ec : [??????], Ic : [??????], Oc : [??????], Uc : [??????] ];
		foreach (ch, mcods; whole_vyanjans) { 
			addMatch([ch, rc, ac], null, 1, __LINE__); // Used with letters like ???????????? + a e i o u
			addMatch([ch, rc, ac, ic], [??????], 0, __LINE__); // Used with letters like ???????????? + a + i
			addMatch([ch, rc, ac, oc], [kau], 0, __LINE__); // Used with letters like ???????????? + a + o

			foreach (k, v; signsArr) { addMatch([ch, rc, k ], [v[0]],  1, __LINE__); }
		}
		//addSignMatchesForLetter([Nc, mc], [???, chdk, ???]);
		//addMatch([ac, ac, jc, nc, jc], [chdk, ???, chdk], 1); // Special case for  



		// N Special matches 
		ushort[][char] NCombos = [	dc : [???, chdk, ???, chdk], gc : [???, chdk], jc : [???, chdk, ???, chdk], Jc : [???, chdk, ???, chdk], 
									kc : [???, chdk, ???, chdk], mc : [???, chdk, ???, chdk], tc : [???, chdk, ???, chdk], Tc : [???, chdk, ???, chdk]];
		foreach (c, arr; NCombos) { addMatch([Nc, c], arr, 1, __LINE__);} // 		

		addMatch([tc, hc], [???, chdk], 4, __LINE__);  // ??????
		addMatch([tc,hc, hc], [???, chdk], 2, __LINE__);  // ???
		addMatch([Tc, hc], [???, chdk, ???, chdk], 4, __LINE__); // ?????????
		addMatch([Tc, Hc], [???, chdk, ???, chdk], 4, __LINE__); // ????????? 
		addMatch([tc, hc, tc, hc], [???, chdk], 2, __LINE__); // ?????????
		addMatch([tc, hc, Hc], [???, chdk], 0, __LINE__); // ????????? 
		addMatch([tc, hc, Hc, ac, ac], [??????], 0, __LINE__); // ????????? + ?????? 

		addMatch([Tc, hc, hc], [???, chdk], 2, __LINE__); // 
		addMatch([Tc, Hc, hc], [???, chdk], 2, __LINE__); // 
		addMatch([tc, hc, tc, hc, hc], [???, chdk], 2, __LINE__); //
					
		addMatch([nc, nc, mc], [ anu], 0, __LINE__);
		addMatch([rc, rc, yc], [???], 0, __LINE__);				
		addMatch([rc, rc], [???, chdk], 1, __LINE__);	
		//addMatch([xc, xc], [], 4, __LINE__);	

		// Write a dic for koots and add sign matches for that koots.
		char[][] kootsEng = [[Tc, hc, ac, ic]];
		ushort[][] kootsMal = [[???, chdk, ???, ??????]];
		for (size_t i = 0; i > kootsEng.length; ++i) {addMatch(kootsEng[i], kootsMal[i], 0, __LINE__);}	

		
		addMatch([Uscore, Uscore], [0x005F], 0, __LINE__); // two shift underscore = underscore.

	}	

	enum ushort[char] sm_signs = [ ac: ??????, ec: ??????, ic: ??????, oc: ??????, uc: ??????, scc : chdk] ;
	enum ushort[char] bg_signs = [Ac: ??????, Ec: ??????, Ic: ??????, Oc: ??????, Uc: ??????, Rc: ??????];
	enum ushort[char] chdk_signs = [wc : ???, vc : ???, rc : ???, yc : ???, Rc : ??????];
	enum ushort[char] bgs_special = [ac: ??????, ec: ??????, ic: ??????, oc: ??????, uc: ??????];

	void createChillMatches(KeyData kd) {		
		foreach (ch, sign; sm_signs) { 
			ushort[] spCode = ch == ac ? [kd.base] : [kd.base, sign]; // if it's 'a', then we need just chill base
			if (kd.echar == Rc) {
				addMatch([kd.echar, ch], spCode, 2, __LINE__);
			} else {
				addMatch([kd.echar, ch], spCode, 1, __LINE__);
			}
			 

			if (ch == ac) {
				addMatch([kd.echar, kd.echar, ch], null, 1, __LINE__);
			} else {
				addMatch([kd.echar, kd.echar, ch], [sign], 1, __LINE__);
			}
		}
		foreach (ch, sign; bg_signs) { // big signs
			if (kd.echar == Rc && ch == Rc) {
				addMatch([kd.echar, ch], kd.dpCode, 2, __LINE__); // This must be ???
			} else {
				addMatch([kd.echar, ch], [kd.base, sign], 1, __LINE__);
			}			
		} 

		foreach (ch, sign; bgs_special) {
			if ( ch == ac) {
				addMatch([kd.echar, ch, ch], [sign], 0, __LINE__);
				addMatch([kd.echar, kd.echar, ch, ch], [sign], 0, __LINE__);
			} else { 
				addMatch([kd.echar, ch, ch], [sign], 1, __LINE__);
				addMatch([kd.echar, kd.echar, ch, ch], [sign], 1, __LINE__);
			}
		}
		foreach (ch, sign; chdk_signs) { // special signs
			if (kd.echar == rc && ch == rc) {
				addMatch([kd.echar, ch], [???, chdk], 1, __LINE__);
			} else if (kd.echar == Rc && ch == Rc) {
				addMatch([kd.echar, ch], [???], 2, __LINE__);
				
			} else {
				addMatch([kd.echar, ch], [kd.base, chdk, sign, chdk], 1, __LINE__);
			}
			  
		}

		addMatch([kd.echar, ac, ic], [0x0D48], 0, __LINE__);  // ???
		addMatch([kd.echar, ac, uc], [0x0D57], 0, __LINE__); // ???
		addMatch([kd.echar, yc], [kd.base, chdk, ???, chdk], 1, __LINE__);
		addMatch([kd.echar, kd.echar, ac], [??????], 0, __LINE__); // double chill + a match.
	}	
	
	void createConsosMatches(KeyData kd) {				
		foreach (ch, sign; sm_signs) { 
			if (ch == ac) {
				addMatch([kd.echar, ch], null, 1, __LINE__); // Just a backspace is enough. Bcause, we want to delete the chdk
			} else {
				addMatch([kd.echar, ch], [sign], 1, __LINE__);
			}
		}
		foreach (ch, sign; bg_signs) { addMatch([kd.echar, ch], [sign], 1, __LINE__); } // big signs
		//foreach (ch, sign; bgs_special) { addMatch([kd.echar, ch, ch], [sign], 1, __LINE__); }
		foreach (ch, sign; chdk_signs) { addMatch([kd.echar, ch], [sign, chdk], 0, __LINE__); } // signs with chdk + code

		addMatch([kd.echar, ac, ic], [0x0D48], 0, __LINE__); // ???
		addMatch([kd.echar, ac, uc], [0x0D57], 0, __LINE__); 	// ???
	}

	void createDoublerMatches(KeyData kd) {		 
		if (kd.kind == KeyKind.chill) {				
			addMatch([kd.echar, kd.echar], kd.dpCode, 1, __LINE__);
			//writefln("Rc's kd.dpCode %s - %-(0x%X %)", kd.echar, kd.dpCode);
		} else {			
			//[kd.spCode[0], chdk, kd.spCode[0]];
			if (kd.echar == Rc) {
				addMatch([kd.echar, kd.echar], kd.dpCode, 1, __LINE__);
				
			} else {
				addMatch([kd.echar, kd.echar], kd.spCode ~ chdk, 0, __LINE__);
			}
					
		}		 
					
	}

	void createDoubleSignMatches() {
		foreach (ch; signable_consos) {			
			addMatch([ch, ac], null, 1, __LINE__);			
			addMatch([ch, ec], [??????], 1, __LINE__);
			addMatch([ch, ic], [??????], 1, __LINE__);
			addMatch([ch, oc], [??????], 1, __LINE__);
			addMatch([ch, uc], [??????], 1, __LINE__);

			addMatch([ch, ac, ac], [??????], 0, __LINE__);
			addMatch([ch, ec, ec], [??????], 1, __LINE__);
			addMatch([ch, ic, ic], [??????], 1, __LINE__);
			addMatch([ch, oc, oc], [??????], 1, __LINE__);
			addMatch([ch, uc, uc], [??????], 1, __LINE__);
		}		

		foreach (ch, ua; dbl_kp_consos) {
			foreach (v, sign; bgs_special) {				
				if (v == ac) {
					addMatch([ch, ch, v], null, 1, __LINE__);
					addMatch([ch, ch, v, v], [sign], 0, __LINE__);
				} else {					
					addMatch([ch, ch, v, v], [sign], 1, __LINE__);
				}
			}
			addMatch([ch, ch, ec], [??????], 1, __LINE__);
			addMatch([ch, ch, ic], [??????], 1, __LINE__);
			addMatch([ch, ch, oc], [??????], 1, __LINE__);
			addMatch([ch, ch, uc], [??????], 1, __LINE__);
		}		

	}

	//void createLeftSideSigns(char[] ech, ushort[] mcodes, size_t bsp) {
	//	ushort[char] lsSigns = [ec : ??????, Ec : ??????, oc : ??????, Oc : ??????];
	//	//foreach ()
	//}

	// KeyData getKeyData(char c) {
	// 	foreach (kd; keyList) {if (kd.echar == c) return kd;}
	// 	return null;
	// }

	

// End of my own map rules	
	

	void printMx(ushort[] ua) { writefln("[%(0x%X, %)]", ua);}  // 
	char toChar(ushort c) {return cast(char) c;}	
	
	void fillKeyList() {
		// Creating keyData for all possible keys array

		createKeyData(scc, chdk, scc); // chandrakkala on semicolon
		createKeyData(SCc, [0x003A], null); // chandrakkala on semicolon
		createKeyData(hyp, [uHyp], null); // hyphen,

		foreach (c, arr; all_vowel_chars) { createKeyData(c, arr );	} // All vowels 

		foreach (i, ch; chill_chars_arr) { // all chills			
			createKeyData(ch, chill_codes_arr[i], chill_doubles_arr[i], chill_bases_arr[i]);

		} 	
		
		foreach (c, arr; dbl_kp_consos) { createKeyData(c, arr, [arr[0], chdk, arr[0]]); } // all doubling letters
		foreach (c, arr; sin_kp_consos) { createKeyData(c, arr, null); } // all single press letters
	}		

//--------------------------------------------------------------------------------------------------------------------------------------

	T[][] ArrayDup(T)(T[] a) {	// give [a, b, c] - return [[a, a], [b, b], [c, c]]		
		T[][] q ;	
		static if (T.stringof == "char") {
			foreach (T c; a) {q ~= [c, c];}			
		} else {
			foreach (T w; a) {q ~= [w, chdk, w];}			
		}		
		return q;
	}


	T[][] ArrayMix(T)(T[] a, T[] b) {	// give [a, b] & [c] - return [[a, c], [b, c], [c, c]]
		T[][] q ;
		foreach (T c; a) { foreach (T d; b) {q ~= [c, d];} }	
		return q;
	}

	T[][] ArrayMix(T)(T[][] a, T[] b) { // give [[a, b], [a, c]] & [d] - return [[a, b, d], [a, c, d]]
		T[][] q ;
		foreach (cm; a) {foreach (T d; b) {q ~= cm ~ d;} }	
		return q;
	}

	bool isInArray(char ch, char[] cArr)  {	
		foreach (c; cArr) {if (c == ch) return true;}
		return false;
	}


//vars 
	KeyData[56] keyList;
	bool myBspaceSent;
	MatchCopy mCopy;
	int matchId;
	char[] context;
	char currChar; // this char holds the current eng letter 
	int knum = 0;
	MatchData[] matchList;	
	bool shiftPressed;
	bool altOrCtrlPressed;
	int maxRuleLength ;
		
	Window win ;
	Button btn ;
	Label lblM, lblE, lblC, lblRes;
	bool isHooked;
	LRESULT kbProcResult;
	HHOOK dHook;
// vars

void logMatchesToFile() {
	string[] s;
	foreach (m; matchList) { s ~= m.toStr;}	
	toFile(s, "matches.txt");
}

void main() { 	 
	
	fillKeyList();	
	//generateMatchesNew();
	generateMatches(); //----------------Temporarily turned off to experiment with new keymap rule.
	print("match count", matchList.length);	
	//logMatchesToFile();	
	
	win = new Window("Dime - Malayalam IME Tool by Vinod") ;
	win.width = 400;
	win.height = 80;
	win.style = WindowStyle.fixedSingle;
	
	win.onHotKeyPress = &onHkeyPress;
	win.onLoad = &onWinLoad;
	win.onClosing = &onWinClose;
	win.winState = WindowState.minimized;
	win.create;

	btn = new Button(win,"Run Code", 50, 50, 120, 28 ) ;
	btn.create;
	btn.onMouseClick = &btnClick;

	lblC = new Label(win, "Context", 50, 90);
	lblC.font = new Font("Calibri", 14);
	lblC.create;

	lblE = new Label(win, "English", 50, 115);
	lblE.font = new Font("Calibri", 14);
	lblE.create;

	lblM = new Label(win, "Malayalam", 50, 145);
	lblM.font = new Font("Manjari", 14);
	lblM.create;

	lblRes = new Label(win, "Result", 50, 185);
	lblRes.font = new Font("Manjari", 14);
	lblRes.create;	
	//foreach (kd; keyList) {writefln("echar : %s, spCode : %s, dpCode : %s", kd.echar, kd.spCode, kd.dpCode);}
	win.show;			
}

void onWinLoad(Control c, EventArgs e) { 	
	HotKeyStruct hk ;
	hk.altKey = true;
	hk.hotKey = Key.q;
	win.registerHotKey(&hk);
//	log("Register hot key : ", hk.result);
	dHook = SetWindowsHookExW(WH_KEYBOARD_LL, &myKeyBoardHookProc, win.hInstace, 0);
	if (dHook == null) {
		print("hooking failed");
	} else {
		isHooked = true;
		print("Hook injected");
	}	
}

void btnClick(Control c, EventArgs e) {	
	
}

void onHkeyPress(Control c, HotKeyEventArgs e) {
	if (!isHooked) {
		dHook = SetWindowsHookExW(WH_KEYBOARD_LL, &myKeyBoardHookProc, win.hInstace, 0);
		if (dHook == null) {
			print("hooking failed");
		} else {
			isHooked = true;
			print("Hook injected");
		}	
	} else {
		if (isHooked) {
			auto res = UnhookWindowsHookEx(dHook);
			if (res > 0) {
				print("Unhook Success", res);
				isHooked = false;
			}
		}
	}
}

void onWinClose(Control c, EventArgs e) {
	if (isHooked) {
		auto res = UnhookWindowsHookEx(dHook);
		print("Unhook result", res);
	}
}

bool isHookNeeded(DWORD vkey, DWORD extraInfo) {
	if (vkey == 8 && extraInfo == 1) {
		//myBspaceSent = true;
		//print("Back space with extra info");
		return false;	
	}
	if (altOrCtrlPressed) return false;
	if (vkey == VK_PACKET) {
		return false;
	} else {		
		if (vkey in vkc_char_dic) return true;
	}	
	return false;	
}

//void sentBackSpaceOnKeyUp() {
//	INPUT[] ip;
//	KEYBDINPUT kb;
//	ip[0].type = INPUT_KEYBOARD;
//	kb.wVk = VK_BACK;
//	kb.dwExtraInfo = 1; // This is vital. We can differentiate our back space & users backspace.
//	kb.dwFlags = KEYEVENTF_KEYUP;
//	ip[0].ki = kb;
//	SendInput(1, ip.ptr, inpSize);

//}

void processKey(bool kUp) {	
	scope(failure) {
		auto res = UnhookWindowsHookEx(dHook);
		if (res == 1) isHooked = false ;
		print("Unhook result", res);		
	}		
	
	bool found;
	if (context.length > 0) {	
		foreach (mt; matchList) {
			if (mt.echars == context) {
				found = true;
				//printMatchAndContext(mt, true);
				mCopy.bFound = true;
				mCopy.match = mt;				
				makeInputsFromMatch(mt, kUp);				
				break;
			}
		}		
	} 

	if (!found) { // There is no matches in match list.
		if (context.length > 1) {
			//so lets recursively search
			auto indx = recursiveSearch(1);
			if (indx != -1) { 	
				found = true;
				auto mt = matchList[indx];
				mCopy.bFound = true;
				mCopy.match = mt;				
				//printMatchAndContext(mt, false);
				makeInputsFromMatch(mt, kUp);
				//SendInput(inps.length, inps.ptr, inpSize);
								
			}
		}
		
		if (!found) {
			//print("current char", currChar);
			foreach ( kd; keyList) {			
				if ( kd.echar == currChar) { 
					//print("Find current char in KeyList", kd.echar);
					mCopy.ccmCode = kd.spCode;					
					sendCurrentChar(kd.spCode, kUp);
					
					break;
				} 				
			}	
		}
	}	
}




int recursiveSearch(size_t len ) {
	auto nContext = context[len..$];
	
	if (nContext.length == 1) {return -1;}
	bool found1;
	foreach (i, mt; matchList) {
		if (mt.echars == nContext) {			
			found1 = true;
			return i;
		}
	}
	if (!found1) {		
		++len;
		return recursiveSearch(len);
	}
	return -1;
}

void resetContext() {
	if (context.length == maxRuleLength) {
		context[0] = currChar;
		context.length = 1;
		context.assumeSafeAppend;
	}	
}

void sendCurrentChar(ushort[] mcods, bool k) {	
	INPUT[] ips;
	foreach (ushort mc; mcods) {ips ~= makeOneLetter(mc, k);}
	//foreach (ushort mc; mcods) {ips ~= makeOneLetter(mc, true);}
	//ips ~= makeOneLetter(chdk, k);
	SendInput(ips.length, ips.ptr, inpSize);	
	//print("current char's input result", res);
}

void makeInputsFromMatch(MatchData md, bool ks) {	
	//INPUT[] ips; // For sending backspaces keys
	//for (int i; i < md.bspaces; ++i) {ips ~= makeOneBackSpace(ks);}	
	//for (int i; i < md.bspaces; ++i) {ips ~= makeOneBackSpace(true);}
	//foreach (ip; ips) {ip.ki.dwFlags = KEYEVENTF_KEYUP;}
	//SendInput(ips.length, ips.ptr, inpSize);
	for (int i; i < md.bspaces; ++i) { 
		auto ip= makeOneBackSpace(false);
		SendInput(1, &ip, inpSize);
		ip.ki.dwFlags = KEYEVENTF_KEYUP;
		SendInput(1, &ip, inpSize);
	}
	//print("back spaces key sent result", res);

	INPUT[] ips2; // For sending Malayalam keys
	foreach (ushort key; md.spCode) {ips2 ~= makeOneLetter(key, ks);}
	SendInput(ips2.length, ips2.ptr, inpSize);
	// foreach (ushort key; md.spCode) {ips ~= makeOneLetter(key, ks);}
	// SendInput(ips.length, ips.ptr, inpSize);
	 
}



void printMatchAndContext(MatchData m, bool mains) {	
	if (mains) {
		writefln(fmt, m.idNum, "Main area", m.echars, m.spCode, context, m.bspaces);
	} else {
		writefln(fmt, m.idNum, "recursion area", m.echars, m.spCode, context, m.bspaces);
	}
}

INPUT makeOneLetter(ushort letter, bool keyUp) {	
	KEYBDINPUT kb;	
	kb.wScan = letter;
	kb.wVk = 0;
	kb.dwFlags = keyUp ? KEYEVENTF_UNICODE|KEYEVENTF_KEYUP : KEYEVENTF_UNICODE ;

	INPUT ip;
	ip.type = INPUT_KEYBOARD;
	ip.ki = kb;
	return ip;	
}

INPUT makeOneBackSpace(bool keyUp) {	
	KEYBDINPUT kb;	
	kb.wVk = VK_BACK;
	kb.dwExtraInfo = 1; // This is vital. We can differentiate our back space & users backspace.
	//kb.dwFlags = keyUp ? KEYEVENTF_UNICODE | KEYEVENTF_KEYUP : KEYEVENTF_UNICODE;
	if (keyUp) kb.dwFlags = KEYEVENTF_KEYUP;

	INPUT ip;
	ip.type = INPUT_KEYBOARD;
	ip.ki = kb;
	return ip;
}

void setContext(DWORD vkey) {	
	if (vkey != VK_PACKET) {		
		if (shiftPressed) {
			currChar = VKC_CHAR_DIC[vkey];
			// print("vkey", vkey);
		} else {
			currChar = vkc_char_dic[vkey];				
		}
		context ~= currChar;				
	}
}

void clearContext() {	
	context.length = 0;
	context.assumeSafeAppend;	
}

// KeyData getKeyData(char eChar) {	
// 	foreach (kd; keyList) {
// 		if (kd.echar == eChar) {return kd;}
// 	}
// 	return null;
// }

extern(Windows)
LRESULT myKeyBoardHookProc(int nCode, WPARAM wp, LPARAM lp) nothrow {
	try {
		if (nCode == HC_ACTION) {
			auto kbs = cast(KBDLLHOOKSTRUCT*) lp ;
			switch (wp) {
				case WM_KEYDOWN :	
					if (kbs.vkCode == 160 || kbs.vkCode == 161) shiftPressed = true ;
					if (kbs.vkCode == 162 || kbs.vkCode == 163 ) altOrCtrlPressed = true;
					//print("under score", kbs.vkCode); 160 + 189
					if (kbs.vkCode == VK_SPACE || kbs.vkCode == VK_RETURN) clearContext();

					//if (kbs.vkCode == VK_BACK ) print("key down on back space");

					if (isHookNeeded(kbs.vkCode, kbs.dwExtraInfo)) {
						setContext(kbs.vkCode);	
						// auto sw = StopWatch();
						// sw.start();
						processKey(false);
						// sw.stop();
						// print("processing time", sw.peek());
						
						return !(kbs.vkCode == VK_BACK || kbs.vkCode == VK_SPACE);						
					} 

					//return CallNextHookEx(null, nCode, wp, lp)	;			
					break;

				case WM_KEYUP :
					
					if (altOrCtrlPressed) altOrCtrlPressed = false;
					if (shiftPressed) {if (kbs.vkCode == 160 || kbs.vkCode == 161) shiftPressed = false;}

					//if (kbs.vkCode == VK_BACK ) print("key up on back space");
						
					
					if (!isHookNeeded(kbs.vkCode, kbs.dwExtraInfo)) {
						// if (mCopy.bFound) {
						// 	makeInputsFromMatch(mCopy.match, true);
						// } else {
						// 	sendCurrentChar(mCopy.ccmCode, true);
						// }				
						//return !(kbs.vkCode == VK_BACK || kbs.vkCode == VK_SPACE);	
						if (!kbs.vkCode == VK_PACKET) {clearContext(); }					
					} 
					// else {

					// 	if (!kbs.vkCode == VK_PACKET) {clearContext(); }
						
					// }

					//return CallNextHookEx(null, nCode, wp, lp)	;
					break;
				default : break;
			}		
		}
		return CallNextHookEx(null, nCode, wp, lp);
	} 
	catch (Exception e){ }	
	return CallNextHookEx(null, nCode, wp, lp);

} 
	

