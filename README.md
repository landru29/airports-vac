# Keep updated your Airports

airport-a5 is a Command Line Interface to download french airport documents. It generates the A5 paper format.

## Dowload one airport

```bash
./airport-a5.sh --oaci LFRN --oaci LFRT
```

to generate the a5 paper format:

```bash
./airport-a5.sh --oaci LFRN --a5
```

## Download many airports

1 - Create a json file ` list.json`:

```json
[
    {
        "filename": "LFEB-Dinan.pdf",
        "oaci": "LFEB"
    },
    {
        "filename": "LFED-Pontivy.pdf",
        "oaci": "LFED"
    }
]
```

2 - Launch

```bash
./airport-a5.sh --json ./list.json
```

3 - with A5 format paper:

```bash
./airport-a5.sh --json ./list.json --a5
```
