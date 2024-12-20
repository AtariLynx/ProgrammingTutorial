/*
 *	API of the "8bit-Hub" for CC65
 *	
 *	Last modified: 2022/02/23
 *	
 * Copyright (c) 2022 Anthony Beaucamp.
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *   1. The origin of this software must not be misrepresented * you must not
 *   claim that you wrote the original software. If you use this software in a
 *   product, an acknowledgment in the product documentation would be
 *   appreciated but is not required.
 *
 *   2. Altered source versions must be plainly marked as such, and must not
 *   be misrepresented as being the original software.
 *
 *   3. This notice may not be removed or altered from any distribution.
 *
 *   4. The names of this software and/or it's copyright holders may not be
 *   used to endorse or promote products derived from this software without
 *   specific prior written permission.
 */

// HUB Client Version
#define HUB_CLIENT_VER	  1
#define HUB_BUFFER_LEN	256
#define HUB_SEND_RETRY    8

// HUB Status Flags
#define COM_ERR_OK        0
#define COM_ERR_OFFLINE   1
#define COM_ERR_HEADER    2 
#define COM_ERR_TRUNCAT   3
#define COM_ERR_CORRUPT   4

// HUB Commands
#define HUB_SYS_ERROR     0
#define HUB_SYS_RESET     1
#define HUB_SYS_IP        5
#define HUB_SYS_STATE     9
#define HUB_DIR_LS       10
#define HUB_DIR_MK       11
#define HUB_DIR_RM       12
#define HUB_DIR_CD       13
#define HUB_FILE_OPEN    21
#define HUB_FILE_SEEK    22
#define HUB_FILE_READ    23
#define HUB_FILE_WRITE   24
#define HUB_FILE_CLOSE   25
#define HUB_UDP_OPEN     30
#define HUB_UDP_RECV     31
#define HUB_UDP_SEND     32
#define HUB_UDP_CLOSE    33
#define HUB_UDP_SLOT     34
#define HUB_TCP_OPEN     40
#define HUB_TCP_RECV     41
#define HUB_TCP_SEND     42
#define HUB_TCP_CLOSE    43
#define HUB_TCP_SLOT     44
#define HUB_WEB_OPEN     50
#define HUB_WEB_RECV     51
#define HUB_WEB_HEADER   52
#define HUB_WEB_BODY     53
#define HUB_WEB_SEND     54
#define HUB_WEB_CLOSE    55
#define HUB_URL_GET      60
#define HUB_URL_READ     61

// HUB Functions
unsigned char InitHub(void);
unsigned char SendHub(unsigned char cmd);
unsigned char RecvHub(unsigned char cmd);

// HUB Variables
extern unsigned char hubState[7], hubOutLen, *hubOutBuffer, hubInLen, hubInBuffer[HUB_BUFFER_LEN];