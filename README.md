# Verilog_YOLO

YOLO function 블록 대신, 하드웨어 아키텍처용 기본 연산 블록과 PE를 포함한 Verilog 설계입니다.

## Folder layout
- `function/`: core modules (.v)

## Modules
- `function/adder8_seq.v`
  - 8-bit carry lookahead 가산기(CLA)
  - propagate/generate 비트 연산으로 carry를 병렬 계산
  - `start` 후 1클락 뒤 결과(`sum`, `carry_out`)와 `done` 출력

- `function/multiplier8_seq.v`
  - 8-bit 순차 곱셈기
  - shift-and-add 비트 연산 기반
  - `start` 이후 8클락 연산, 완료 시 `done` 출력

- `function/pe27_mac.v`
  - 27개의 weight와 27개의 input을 받아 MAC 수행
  - 각 항은 `wi * xi`를 `multiplier8_seq`로 계산
  - 누산은 `adder8_seq`만 사용해 24-bit 누적값으로 합산
  - 내부는 FSM + wire 연결 기반으로 구성
