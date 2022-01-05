extern char _cdecl mem_cmp(char* str1, char* str2, short strSize)
{
    char checker = 0x00;
    for (short i = 0; i < strSize; i++)
    {
        if (str1[i] != str2[i])
        {
            checker = 0x01;
        }
    }
    return checker;
}

extern void _cdecl mem_cpy(char* str1, char* str2, short strSize)
{
    for (short i = 0; i < strSize; i++)
    {
        str2[i] = str1[i];
    }
    return;
}

//TODO 0 в последний байт, либо в байт за последним?
extern void _cdecl str_init(char* str1, short strSize)
{
    str1[strSize - 1] = 0x00;
}

extern char _cdecl str_cmp(char* str1, char* str2)
{
    char checker = 0x00;
    char flag = 0x01;
    short i = 0;
    if ((str1[i] == 0x00)  || (str2[i] == 0x00))
        flag = 0x00;
    do
    {
        if (str1[i] != str2[i])
            checker = 0x01;
        if ((str1[i + 1] == 0x00) || (str2[i + 1] == 0x00))
            flag = 0x00;
    } while (flag);
    return checker;
}

//TODO extern void str_cpy(char* str1, char2* str2)

extern void _cdecl message_crypt(char* in, short inSize, char* key, short keySize, char* out)
{
    short iter = inSize / keySize;
    short remain = inSize % keySize;
    if (remain == 0)
    {
        if (iter == 1)
        {
            for (short i = 0; i < inSize; i++)
            {
                out[i] = in[i] ^ key[i];
            }
            return;
        }
    }
    short j = 0;
    for (j; j < iter; j++)
    {
        for (short i = 0; i < keySize; i++)
        {
            out[j * keySize + 1] = in[j * keySize + i] ^ key[i];
        }
    }
    for (short i = 0; i < remain; i++)
    {
        out[j * keySize + i] = in[j * keySize + i] ^ key[i];
    }
    return;
}

extern void _cdecl message_decrypt(char* in, short inSize, char* key, short keySize, char* out)
{
    message_crypt(in, inSize, key, keySize, out);
}


extern const unsigned short crcTab[];
unsigned short _cdecl crc (const char* s, short n)
{
	unsigned short result = 0;
	for (int i = 0; i < n; i++)
		result = (result << 8) ^ crcTab[((result >> 8) ^ *s++) & 0xFF];
	return result;
}

extern void _cdecl crc_calc(char* in, short* inSize, char* out)
{
    short temp = *inSize / 8;
    short remain = *inSize % 8;
    short a = 0;
    for (short i = 0; i < temp + remain; i++)
    {
            for (short j = 0; j < 8; j++)
            {
                    a = 0x03 & (((0xC0 & in[0]) >> 6) | (0x03 & in[0]) | ((0x30 & in[1]) >> 4) | (0x03 & in[1]));
                    out[0] = (in[0] << 2) | (in[1] >> 6);
                    out[1] = (in[1] << 2) | temp;
            }
            //if (a == temp + remain)
            //{
					//password_check(in,inSize, out);
              //      return;
            //}
    }
	//password_check(in,inSize, out);
	//return;
}

void _cdecl password_check (char* in, short* inSize, char* out)
{
	//crc_calc(in,inSize,out);
  *inSize = 0xC8D9 == crc(in, *inSize);
}








/*
static const unsigned short crcTab[256] =
{   0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
    0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
    0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
    0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
    0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
    0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
    0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
    0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
    0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
    0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
    0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
    0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
    0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
    0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
    0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
    0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
    0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
    0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
    0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
    0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
    0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
    0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
    0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
    0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
    0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
    0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
    0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0 };

extern unsigned short _cdecl crc(const char* in, short inSize)
{
    unsigned short crc = 0;
    for (short i = 0; i < inSize; i++)
    {
        crc = (crc << 8) ^ crcTab[((crc >> 8) ^ *in++) & 0x00FF];
    }
    return crc;
}

unsigned short checker = 0x8144;



extern void _cdecl password_check(char* in, short inSize, char* in2)
{   
    puts(in);
    unsigned short temp = crc(in, inSize);
    if (checker == temp)
    {
        *in2 = 0x01;
    }
    else 
    {
        *in2 = 0x00;
    }
    puts(in2)
}*/
