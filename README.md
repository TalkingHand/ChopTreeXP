# Chop Tree XP

Project Zomboid **Build 42** mod. Grants Strength, Fitness and Axe XP on every hit of the automatic right-click **Chop Tree** action.

In vanilla B42, only a manual hit on a tree gives XP (`Events.OnWeaponHitTree`, Strength +2). The automatic Chop Tree action (`ISChopTreeAction`) never fires that event, so it gives no XP at all.

[한국어](#한국어)

## XP per hit

| Skill | XP per hit | Basis |
|---|---|---|
| Strength | 4.8 | One burpee rep (vanilla `Fitness.incStats`: arms 4 + chest 2, × burpee xpMod 0.8) |
| Fitness | 3.2 | One burpee rep (legs 4 × 0.8) |
| Axe | tree health removed × ~0.086 | Same Axe XP per tree for every axe. Calibrated on the Fire Axe |

Values are before the server XP multipliers. Axe XP is given only for axe-category weapons.

| Axe XP | Hand Axe | Fire Axe | Wood Axe |
|---|---|---|---|
| Per hit | 1.3 | 3.0 | 4.8 |
| Per tree (240 HP) | 20.7 | 20.7 | 20.7 |

## How it works

`ISChopTreeAction:animEvent` is wrapped. The vanilla function is called first, unchanged. No vanilla file is replaced.

In vanilla `animEvent`, the `if not isClient()` branch is the one that applies the hit: in singleplayer it runs in the local game, and in multiplayer it runs on the server (the server emulates the `ChopTree` event every 1500 ms from `serverStart`). The client branch only plays effects. The mod grants XP under the same condition, so each hit grants XP exactly once, and server-side `addXp` syncs to the client. This is the same pattern as the vanilla `ISHutchGrabEgg` and `ISGiveWaterToAnimal`.

## Sandbox options

| Option | Default |
|---|---|
| Strength XP from Chop Tree | on |
| Strength XP multiplier | 1.0 |
| Axe XP from Chop Tree | on |
| Axe XP multiplier | 1.0 |
| Fitness XP from Chop Tree | on |

## Install

- Steam Workshop: subscribe, then enable **Chop Tree XP** in the mod list.
- Manual: copy `Contents/mods/ChopTreeXP` to `%USERPROFILE%\Zomboid\mods\`.
- Multiplayer: add the mod to the server. All players need it too.

Do not use it together with other chop-tree XP mods, because XP would stack.

## Repository layout

The repository uses the Project Zomboid Workshop upload layout (`%USERPROFILE%\Zomboid\Workshop\<name>\`):

```
workshop.txt                      Workshop title / description / tags
preview.png                       Workshop preview (256x256)
Contents/mods/ChopTreeXP/
  common/
  42/
    mod.info
    poster.png
    media/sandbox-options.txt
    media/lua/shared/ChopTreeXP.lua
    media/lua/shared/Translate/{EN,KO}/Sandbox.json
```

## License

[MIT](LICENSE)

---

## 한국어

Project Zomboid **Build 42**용 모드입니다. 우클릭 **나무 베기**(자동 벌목)로 나무를 칠 때마다 근력·체력·도끼 경험치를 지급합니다.

바닐라에서는 나무를 직접 때릴 때만 근력 +2를 줍니다. 자동 벌목은 그 이벤트(`OnWeaponHitTree`)를 거치지 않아서 경험치가 0입니다.

### 타격 1회당 경험치

- **근력 4.8, 체력 3.2**: 버피 1회와 같은 양입니다. 타격 횟수에 비례합니다.
- **도끼**: 그 타격에서 깎은 나무 체력에 비례합니다. 도끼 종류와 관계없이 그루당 같은 양이고, 소방 도끼는 1회 약 3입니다.
- 값은 서버 경험치 배율을 적용하기 전 기준입니다. 도끼 경험치는 도끼 계열 무기에만 지급됩니다.

### 멀티플레이

바닐라가 나무 타격을 처리하는 곳(멀티는 서버, 싱글은 로컬 게임)에서 지급하므로, 1회 타격에 정확히 1번만 들어가고 클라이언트로 동기화됩니다. 나무를 직접 때릴 때의 경험치(바닐라)와도 겹치지 않습니다.

### 샌드박스 옵션

- 근력: 켜기/끄기, 배율 (기본 1.0)
- 도끼: 켜기/끄기, 배율 (기본 1.0)
- 체력: 켜기/끄기

### 설치

- 창작마당에서 구독하고 모드 목록에서 켭니다.
- 수동 설치: `Contents/mods/ChopTreeXP` 폴더를 `%USERPROFILE%\Zomboid\mods\`에 복사합니다.
- 멀티: 서버에 모드를 추가합니다. 모든 플레이어가 모드를 가지고 있어야 합니다.

다른 벌목 경험치 모드와 함께 쓰면 경험치가 중복으로 들어가니 함께 쓰지 마세요.
