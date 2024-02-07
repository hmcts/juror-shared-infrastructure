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
  fixed_secrets = {}
  #Non secret parameters used by applications via secrets (instead of env vars) 
  //fixed_secrets = {
  //  "bureau-jwtTTL" = "8h",
  //  "public-jwtTTL" = "8h"
  //}

  //generated_secrets = {
  //   type = set(string)
  //   default = [
  //     "bureau-jwtKey",
  //     "public-jwtKey",
  //     "fe-jwtNoAuthKey",
  //     "bureau-sessionSecret",
  //     "public-sessionSecret",
  //     "pnc-secret",
  //     "scheduler-api-secret",
  //     "scheduler-exe-secret"
  //   ]
  // }
  generated_secrets = {
    "Ian-Test-none" = { secret_length = 32 },    
    "Ian-Test-normal-only" = { secret_length = 32, name = "Ian-Test-normal-only", name2 = null, name64 = null },
    "Ian-Test-64-only" = { secret_length = 32, name = null, name2 = null, name64 = "Ian-Test-64-only" },    
    "Ian-Test-normal-both" = { secret_length = 32, name = "Ian-Test-normal-both", name2 = "Ian-Test-normal-both-Second", name64 = null },
    "Ian-Test-all" = { secret_length = 32, name = "Ian-Test-all", name2 = "Ian-Test-all-Second", name64 = "Ian-Test-all-64" }
  }
}