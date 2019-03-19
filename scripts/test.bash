#!/bin/bash

FROM=0xd2330a9f6dde4715f540d1669bf75e89a1b4fbbc truffle exec scripts/depositTest.js 

FROM=0x7d0344e0ee6bc3901f4b11b9d9b8d001b49872a1 truffle exec scripts/depositTest.js 

FROM=0xd2330a9f6dde4715f540d1669bf75e89a1b4fbbc ACTOR=0x7d0344e0ee6bc3901f4b11b9d9b8d001b49872a1 truffle exec scripts/submitTest.js 
