locals {
  hub = {
    nonprod = {
      subscription = "fb084706-583f-4c9a-bdab-949aac66ba5c"
      ukSouth = {
        name        = "hmcts-hub-nonprodi"
        next_hop_ip = "10.11.72.36"
      }
    }
    sbox = {
      subscription = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
      ukSouth = {
        name        = "hmcts-hub-sbox-int"
        next_hop_ip = "10.10.200.36"
      }
    }
    prod = {
      subscription = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
      ukSouth = {
        name        = "hmcts-hub-prod-int"
        next_hop_ip = "10.11.8.36"
      }
    }
  }
  admin_group_map = {
    "demo" = "DTS Juror Admin (env:demo)"
    "ithc" = "DTS Juror Admin (env:ithc)"
    "test" = "DTS Juror Admin (env:test)"
    "stg"  = "DTS Juror Admin (env:staging)"
    "prod" = "DTS Juror Admin (env:production)"
  }
  #Non secret parameters which are the same across all environments, used by applications via secrets (instead of env vars) 
  fixed_secrets = {
    "bureau-jwtTTL" = "8h",
    "public-jwtTTL" = "8h"
  }

  #Multi functional 'generated_secrets' block to cater for different scenarios - see examples below (first string isn't used, just needs to be unique):
  #NOTES
  #     first string isn't used, just needs to be unique - but also make sense
  #     secret names in vault come from name, name2 and name64 parameters
  #     secrets are min length 9 (because of min_upper, min_lower and min_numeric in secrets.tf)
  
  #  "Test-nothing" = { secret_length = 32, name = null, name2 = null, name64 = null }  
  #  Will create a 32 character password but won't store it anywhere (so don't use)

  #  "Test-normal" = { secret_length = 64, name = "Test-normal-only", name2 = null, name64 = null }
  #  Will create a 64 character password and store the password as a secret named 'Test-normal-only'

  #  "Test-64" = { secret_length = 32, name = null, name2 = null, name64 = "Test-64-only" }  
  #  Will create a 32 character password and store the base64 encoded version of the password as a secret named 'Test-64-only'

  #  "Test-both" = { secret_length = 32, name = "Test-normal-both", name2 = "Test-normal-both-Second", name64 = null }
  #  Will create a 32 character password and store the password as secrets named 'Test-normal-both' and 'Test-normal-both-Second'

  #  "Test-all" = { secret_length = 32, name = "Test-all", name2 = "Test-all-Second", name64 = "Test-all-64" }
  #  Will create a 32 character password and store the password as secrets named 'Test-all' and 'Test-all-Second', 
  #  plus it will store the base64 encoded version of the password as a secret named 'Test-all-64'
  

  generated_secrets = {
    "bureau-jwtKey" = { secret_length = 32, name = "bureau-jwtKey", name2 = "public-jwtKeyBureau", name64 = "api-JWT-SECRET-BUREAU" },
    "public-jwtKey" = { secret_length = 32, name = "public-jwtKey", name2 = null, name64 = "api-JWT-SECRET-PUBLIC" },
    "jwtNoAuthKey" = { secret_length = 32, name = "bureau-jwtNoAuthKey", name2 = "public-jwtNoAuthKey", name64 = "api-JWT-SECRET-HMAC" },    
    "bureau-sessionSecret" = { secret_length = 32, name = "bureau-sessionSecret", name2 = null, name64 = null },
    "public-sessionSecret" = { secret_length = 32, name = "public-sessionSecret", name2 = null, name64 = null }
  }
}