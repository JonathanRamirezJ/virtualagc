### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	KALCMANU_STEERING.agc
# Purpose:	Part of the source code for Colossus build 237.  
#		This is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), we believe for Apollo 8.
# Assembler:	yaYUL
# Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Colossus237/
# Mod history:	2010-06-01 OH	Adapted from corresponding Colossus 249 file.
#		2010-12-04 JL	Remove Colossus 249 header comments. Change to double-has page numbers.

## Page 405
# GENERATION OF STEERING COMMANDS FOR DIGITAL AUTOPILOT FREE FALL MANEUVERS
#
# NEW COMMANDS WILL BE GENERATED EVERY ONE SECOND DURING THE MANEUVER

		BANK	15
		SETLOC	KALCMON1
		BANK
		
		EBANK=	BCDU
		
		COUNT	22/KALC
		
NEWDELHI	CS	HOLDFLAG	# SEE IF MANEUVER HAS BEEN INTERRUPTED
		EXTEND			# BY ASTRONAUT.
		BZMF	NOGO	-2	# IF SO, TERMINATE KALCMANU
NEWANGL		TC	INTPRET
		AXC,1	AXC,2
			MIS		# COMPUTE THE NEW MATRIX FROM S/C TO
			DEL		# STABLE MEMBER AXES
		CALL
			MXM3
		VLOAD	STADR
		STOVL	MIS +12D	# CALCULATE NEW DESIRED CDU ANGLES
		STADR
		STOVL	MIS +6D
		STADR
		STORE	MIS
		AXC,1	CALL
			MIS
			DCMTOCDU	# PICK UP THE NEW CDU ANGLES FROM MATRIX
		RTB	
			V1STO2S
		STORE	NCDU		# NEW CDU ANGLES
		BONCLR	EXIT
			CALCMAN2
			MANUSTAT	# TO START MANEUVER
		CAF	TWO		# 	+0 OTHERWISE
INCRDCDU	TS	KSPNDX
		DOUBLE
		TS	KDPNDX
		INDEX	KSPNDX
		CA	NCDU		# NEW DESIRED CDU ANGLES
		EXTEND
		INDEX	KSPNDX
		MSU	BCDU		# INITIAL S/C ANGLE OR PRVIOUS DESIRED
		EXTEND			# CDU ANGLES
		MP	DT/TAU
		INDEX	KDPNDX
		DXCH	DELCDUX		# ANGEL INCREMENTS TO BE ADDED TO
## Page 406
		INDEX	KSPNDX		# DCDU EVERY TENTH SEC
		CA	NCDU		# BY LEM DAP
		INDEX	KSPNDX
		XCH	BCDU
		INDEX	KDPNDX
		TS	CDUXD
		CCS	KSPNDX
		TCF	INCRDCDU	# LOOP FOR THREE AXES
		
		RELINT
		
# COMPARE PRESENT TIME WTIH TIME TO TERMINATE MANEUVER

TMANUCHK	TC	TIMECHK
		TCF	CONTMANU
		CAF	ONE
MANUSTAL	TC	WAITLIST
		EBANK=	BCDU
		2CADR	MANUSTOP
		
		RELINT
		TCF	ENDOFJOB
		
TIMECHK		EXTEND
		DCS	TIME2
		DXCH	TTEMP
		EXTEND
		DCA	TM
		DAS	TTEMP
		CCS	TTEMP
		TC	Q
		TCF	+2
		TCF	2NDRETRN
		CCS	TTEMP +1
		TC	Q
		TCF	MANUOFF
		COM
MANUOFF		AD	ONESEC +1
		EXTEND
		BZMF	2NDRETRN
		INCR	Q
2NDRETRN	INCR	Q
		TC	Q
		
DT/TAU		DEC	.1

MANUSTAT	EXIT			# INITIALIZATION ROUTINE
		EXTEND			# FOR AUTOMATIC MANEUVERS
		DCA	TIME2
		DAS	TM		# TM+TO		MANEUVER COMPLETION TIME
		EXTEND
## Page 407
		DCS	ONESEC
		DAS	TM		# (TM+TO)-1
		INHINT
		CS	ONE		# ENABLE AUTOPILOT TO PERFORM
		TS	HOLDFLAG	# AUTOMATIC MANEUVERS
		CS	RATEINDX	# SEE IF MANEUVERING AT HIGH RATE
		AD	SIX
		EXTEND
		BZMF	HIGHGAIN
		TCF	+4
HIGHGAIN	CS	RCSFLAGS	# IF SO, SET HIGH RATE FLAG (BIT 15 OF
		MASK	BIT15		# RCSFLAGS)
		ADS	RCSFLAGS
		DXCH	BRATE		# X-AXIS MANEUVER RATE
		DXCH	WBODY
		DXCH	BRATE	+2	# Y-AXIS MANEUVER RATE
		DXCH	WBODY1
		DXCH	BRATE	+4	# Z-AXIS MANEUVER RATE
		DXCH	WBODY2
		CA	BIASTEMP +1	# INSERT ATTITUDE ERROR BIASES
		TS	BIAS		# INTO AUTOPILOT
		CA	BIASTEMP +3
		TS	BIAS1
		CA	BIASTEMP +5
		TS	BIAS2
		CA	TIME1
		AD	ONESEC +1
		XCH	NEXTIME
		TCF	INCRDCDU -1
		
ONESEC		DEC	0
		DEC	100
		
CONTMANU	INHINT
		CS	TIME1		# CONTINUE WITH UPDATE PROCESS
		AD	NEXTIME
		CCS	A
		AD	ONE
		TCF	MANUCALL
		AD	NEGMAX
		COM
MANUCALL	TC	WAITLIST
		EBANK=	BCDU
		2CADR	UPDTCALL

		RELINT
		CAF	ONESEC +1	# INCREMENT TIME FOR NEXT UPDATE
		ADS	NEXTIME
		TCF	ENDOFJOB
## Page 408
		
UPDTCALL	CAF	PRIO26		# CALL FOR UPDATE
		TC	FINDVAC		# OF STEERING COMMANDS
		EBANK=	BCDU
		2CADR	NEWDELHI

		TC	TASKOVER
		
## Page 409
# ROUTINE FOR TERMINATING AUTOMATIC MANEUVERS

MANUSTOP	TC	STOPYZ
		TC	LOADYZ

ENDROLL		CA	CPHI	
		TS	CDUXD		# SET CDUXD TO THE COMMANDED OUTER GIMBAL
		TC	STOPRATE
ENDMANU		CA	ATTPRIO		# RESTORE USERS PRIO
		TS	NEWPRIO
		
		CA	ZERO		# ZERO ATTCADR
		DXCH	ATTCADR
		
		TC	SPVAC		# RETURN TO USER
		
		TC	TASKOVER
		
STOPRATE	CAF	ZERO
		TS	DELCDUX
		TS	DELCDUX	+1	# ZERO ROLL INCREMENTAL ANGLES
		TS	WBODY		# RATE
		TS	WBODY	+1
		TS	BIAS		# BIAS
		
		CS	BIT15		# MAKE SURE HIGH RATE FLAG (BIT 15 OF
		MASK	RCSFLAGS	# RCSFLAGS) IS RESET.
		TS	RCSFLAGS
		
STOPYZ		CAF	ZERO
		TS	DELCDUY		# ZERO PITCH, YAW
		TS	DELCDUY	+1	# INCREMENTAL ANGLES
		TS	DELCDUZ
		TS	DELCDUZ	+1
		TS	WBODY1		# RATES
		TS	WBODY1	+1
		TS	WBODY2
		TS	WBODY2	+1
		TS	BIAS1		# BIASES
		TS	BIAS2
		TC	Q
		
ZEROERROR	CA	CDUX		# PICK UP CDU ANGLES AND STORE IN
		TS	CDUXD		# CDU DESIRED
		CA	CDUY
		TS	CDUYD
		CA	CDUZ
		TS	CDUZD
		TC	Q

## Page 410
LOADCDUD	CA	CPHI		# STORE TERMINAL ANGLES INTO
		TS	CDUXD		# COMMAND ANGLES
LOADYZ		CA	CTHETA
		TS	CDUYD
		CA	CPSI
		TS	CDUZD
		TC	Q
		
