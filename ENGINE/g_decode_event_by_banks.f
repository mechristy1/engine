      subroutine g_decode_event_by_banks(event,ABORT, err)
*-----------------------------------------------------------------------
*-     Purpose and Methods: Pull out individual Fastbus banks from event
*-                          for subsequent decoding
*-
*-     Find the beginning of each ROC bank and send it off to 
*-    "g_decode_fb_bank".
*-
*-     Inputs:
*-         event      Pointer to the first word (length) of an event data bank.
*-
*-     Outputs:
*-        ABORT       success or failure
*-        err         explanation for failure
*-
*-     Created   3-Dec-1993   Kevin Beard, Hampton U.
*-    $Log$
*-    Revision 1.4  1994/04/15 20:34:42  cdaq
*-    ???
*-
* Revision 1.3  1994/02/17  21:30:37  cdaq
* Move ABORT, err args to end of g_decode_fb_bank call
*
* Revision 1.2  1994/02/02  19:59:16  cdaq
* Rewrite without using fbgen routines
*
* Revision 1.1  1994/02/01  20:38:58  cdaq
* Initial revision
*
*-----------------------------------------------------------------------
      IMPLICIT NONE
      SAVE
*
      integer*4 event(*)
*
      character*30 here
      parameter (here= 'g_decode_event_by_banks')
*
      logical ABORT
      character*(*) err
      integer*4 evlength                        ! Total length of the event
      integer*4 bankpointer                     ! Pointer to next bank
*
      include 'gen_data_structures.cmn'
*
      logical WARN
*
*-----------------------------------------------------------------------
*
*
*     Assume that the event is bank containing banks, the first of which is
*     an event ID bank.
*
*     Various hex constants that are used in decode routines should
*     probably be put in an include file.
*

      ABORT = iand(event(2),'FFFF'x).ne.'10CC'x
      if(ABORT) then
         err = here//'Event header not standard physics event'
         return
      endif

      evlength = event(1)
      bankpointer = 3

      ABORT = event(bankpointer+1).ne.'C0000100'x
      if(ABORT) then
         err = here//'First bank is not an Event ID bank'
         return
      endif
      
      bankpointer = bankpointer + event(bankpointer) + 1

      WARN = (bankpointer.gt.evlength)           ! No ROC's in event
      IF(WARN) THEN
        err= ':event contained no ROC banks'
        call G_add_path(here,err)
      ENDIF

      do while(bankpointer.lt.evlength)
         
         call g_decode_fb_bank(event(bankpointer), ABORT, err)
         bankpointer = bankpointer + event(bankpointer) + 1

      enddo

      WARN = bankpointer.eq.(evlength + 1)
      if(WARN) THEN
         err = ':inconsistent bank and event lengths'
         call G_add_path(here,err)
      endif
*
      RETURN
      END



