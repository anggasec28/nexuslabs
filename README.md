<h3 align=center style="font-weight=bold"> NEXUS-LABS ZKVM PROVER </h3>

**System Reuired**
- **RAM**: 4 GB recomended 6GB
- **CPU**: 2 cores
- **Disk Space**: 50 GB

#### Guide

```
bash <(curl -s https://raw.githubusercontent.com/anggasec28/nexuslabs/refs/heads/main/run.sh)
```
atau
```
curl -sSL https://raw.githubusercontent.com/anggasec28/nexuslabs/refs/heads/main/run.sh | bash
```

#### Check Status

Cek Prover Status
```
systemctl status nexus.service
```
Cek Log
```
journalctl -u nexus.service -f -n 50
```

Jika sukses tampilannya seperti dibawah

![IMG_4473](https://github.com/user-attachments/assets/fa6ebb80-2a28-45e7-83d0-b022d72ba418)
