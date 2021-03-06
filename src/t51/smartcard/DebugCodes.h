/**
 * @file   DebugCodes.h
 * @author Lukas Schuller
 * @date   Tue Oct  1 13:35:17 2013
 * 
 * @brief  
 * 
 */

#ifndef DEBUGCODES_H
#define DEBUGCODES_H

#define D_INVALID_PACKET 6
#define D_CRC_ERROR 7
#define D_T51_READY 8
#define D_ISO_L4_ACTIVATED 9
#define D_ISO_L4_DEACTIVATED 10
#define D_PACKET_PROCESSED 11
#define D_ACK_RECEIVED 12
#define D_NAK_RECEIVED 13
#define D_ISO_DESELECT 14
#define D_WTX_ACK      15
#define D_GEN_0        0xA0
#define D_GEN_1        0xA1
#define D_GEN_2        0xA2
#define D_GEN_3        0xA3

#define D_ERR 255


#endif /* DEBUGCODES_H */
