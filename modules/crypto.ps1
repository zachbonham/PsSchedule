

$reference_assemblies = (

	"System.Security.Cryptography, Version=2.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
)

$source = @"

namespace MaryKay.Crypto
{
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Security.Cryptography;

 public class Encryption
    {

        readonly string _key = "5A80ED02";
        readonly string _initVector = "48002233";
        DESCryptoServiceProvider _p = new DESCryptoServiceProvider();

        public Encryption()
        {
            _p.Key = Encoding.ASCII.GetBytes(_key);
            _p.IV = Encoding.ASCII.GetBytes(_initVector);

        }

        public Encryption(byte[] key, byte[] initVector)
        {
            _p.Key = key;
            _p.IV = initVector;
        }

        public string Encrypt(string value)
        {

            if (string.IsNullOrEmpty(value))
            {
                return null;
            }

            string data = null;

            using (MemoryStream ms = new MemoryStream(1024))
            {
                CryptoStream cs = new CryptoStream(ms,
                    new DESCryptoServiceProvider().CreateEncryptor(_p.Key,_p.IV),
                    CryptoStreamMode.Write);

                byte[] byteData = new ASCIIEncoding().GetBytes(value);

                cs.Write(byteData, 0, byteData.Length);
                cs.FlushFinalBlock();

                byte[] result = new byte[(int)ms.Position];

                ms.Position = 0;
                ms.Read(result, 0, result.Length);

                data = System.Convert.ToBase64String(result);
                
            }

            
            return data;
        }

        public string Decrypt(string value)
        {

            if (string.IsNullOrEmpty(value))
            {
                return null;
            }

            string decrypted = null;

            byte[] data = System.Convert.FromBase64String(value);

            using (MemoryStream ms = new MemoryStream(data.Length))
            {

                CryptoStream cs = new CryptoStream(ms, new DESCryptoServiceProvider().CreateDecryptor(_p.Key, _p.IV), CryptoStreamMode.Read);

                byte[] unencrypted = new byte[value.Length];

                ms.Write(data, 0, data.Length);
                ms.Position = 0;

                decrypted = new StreamReader(cs).ReadToEnd();
            }

            return decrypted;
        }

    }
}
"@

add-type -referencedassemblies $referenced_assemblies -typedefinition $source -language CSharp

function encrypt-string([string] $input_string)
{
<#
  .SYNOPSIS
  
  Encrypt a string.    
  
  .PARAMETER $input_string
  
  The input string to encrypt.
  
  .DESCRIPTION
  
  Encrypt a string.    
    
    
  .EXAMPLE
  
  Encrypt the string "testlab!01".
  
  encrypt-string "testlab!01"
  
  Returns the string "nqek+fkHNBXExLzbGeFeng==".
  
#>


	$crypto = new-object marykay.crypto.encryption
	$crypto.Encrypt($input_string)
	
}


function decrypt-string([string] $input_string)
{
<#
  .SYNOPSIS
  
  Decrypt a string.    
  
  .PARAMETER $input_string
  
  The input string to decrypt.
  
  .DESCRIPTION
  
  Decrypt a string.    
    
  .EXAMPLE
  
  Decrypt the string "nqek+fkHNBXExLzbGeFeng==".
  
  decrypt-string "nqek+fkHNBXExLzbGeFeng=="
  
  Returns the string "testlab!01"
  
#>
	$crypto = new-object marykay.crypto.encryption
	
	$crypto.Decrypt($input_string)
}
