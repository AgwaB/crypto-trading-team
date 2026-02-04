# Market Wisdom from Practitioners

Insights collected from trading practitioner discussions (2025-2026).

## Core Truths

### On Strategy Research
> "대부분의 전략은 생각보다 쓸모가 없고 생각보다 돈이 안벌립니다"
> (Most strategies are less useful than you think and make less money than you expect)
— 25년 경력 전업 트레이더

### On Risk vs Research
> "리서치 실력이 형편없어서 망하는 트레이더는 없음"
> (No trader fails because their research skills are poor - it's risk management)
— bellman

### On Market Adaptation
> "단기간에 고수익률을 내는 시스템일수록 대개 장기적으로 더욱 심한 변화에 노출됩니다"
> (Short-term high-return systems face more severe changes long-term)
— Market veteran

## Market State (2025-2026)

### Declining Alpha Sources
| Alpha Source | Status | Notes |
|--------------|--------|-------|
| 김프 (Kimchi Premium) | Declining | 환변동성 too high |
| Funding Rate Arbitrage | Declining | "맛이 없어짐" after Ethena launch |
| DEX Arbitrage | Crowded | Profitable until 2021, now crowded |
| Algo Stablecoin Arb | Crowded | Competition increased significantly |

### Still Viable
| Alpha Source | Status | Notes |
|--------------|--------|-------|
| Cross-exchange Funding Diff | Active | 거래소간 펀비차액 (양빵전략) |
| Microstructure/Order Flow | Active | Requires tick data |
| Multi-Strategy Netting | Active | 400 strategies → Sharpe 2.5 |

## LLM-Based Research (bellman's System)

### Key Metrics
- **Success Rate**: ~31% of LLM-generated strategies show positive Sharpe
- **Portfolio Sharpe**: 2.5 with ~400 strategies combined
- **Cost Assumption**: 20bp round-trip
- **API Cost**: ~$20 Claude API per batch

### Surprising Findings
1. LLM uses non-linear transforms (arctan, sqrt) without explicit instruction
2. LLM generates economically-justified strategies, not just patterns
3. "저보다 나은듯" (It's better than me) — common feedback

## Execution Wisdom

### From Practitioners
- "시그널을 다 실시간으로 계산해야해서 빡시" (Real-time signal calculation is demanding)
- "백테성능 올리는것도 좀 이슈" (Backtest performance optimization is also an issue)
- "메모리릭" (Memory leaks) — most time-consuming debugging

### Technical Recommendations
1. Ray + Python for parallel backtesting
2. Go/Rust for production execution
3. 24+ CPU threads for serious research automation
4. Tick data for microstructure strategies

## Warning Signs

### Strategy Red Flags
1. Works only in one market regime
2. Dominated by few outlier trades
3. >7 tunable parameters
4. OOS degrades >30% from IS

### Market Red Flags
1. "고수들만 남아있어서 간만보는 느낌" (Only experts left, everyone cautious)
2. Volume declining
3. "봇돌려서" everyone running automated bots
4. Spread tightening → "아무나 못씀"

---
*Last Updated: 2026-02-04*
*Source: Trading practitioner discussion analysis*
