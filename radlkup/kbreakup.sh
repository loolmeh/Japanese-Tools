#!/bin/bash

input=($(echo $@))

insertspaces()
{
input=$(echo "$input" | sed 's/./& /g')
input=($input)
}

lookup()
{
  result=$(awk -F"      " '$1 ~ '"/$input/"' {print $4 $7}' kanji)
  result=$(echo "$result" | sed 's/\s//g' | sed 's/\*//g')
}

if [[ $input == "pattern" ]]; then
  echo "一 吅 吕 回 咒 弼 品 叕 冖"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "1" ]] ; then
  echo "一 丨 丶 丿 乀 乁 乙 乚 乛 亅"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "2" ]] ; then
  echo "二 亠 人 亻 儿 入 丷 八 冂 冖 冫 几 凵 刀 刂 力 勹 匕 匚 匸 十 卜 卩 厂 厶 又 讠"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "3" ]] ; then
  echo "口 囗 土 士 夂 夊 夕 大 女 子 宀 寸 小 尢 尸 屮 山 巛 川 工 己 巾 干 幺 广 廴 廾 弋 弓 彐 彑 彡 彳 忄 扌 氵 丬 犭 纟 艹 阝 长 门 阝 飞 饣 马"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "4" ]] ; then
  echo "尣 心 戈 戶 户 手 支 攴 攵 文 斗 斤 方 无 日 曰 月 木 欠 止 歹 殳 毋 比 毛 氏 气 水 火 灬 爪 爫 父 爻 爿 片 牙 牛 犬 王 礻 罓 耂 肀 月 见 贝 车 辶 韦 風 斗"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "5" ]] ; then
  echo "母 氺 玄 玉 瓜 瓦 甘 生 用 田 疋 疒 癶 白 皮 皿 目 矛 矢 石 示 禸 禾 穴 立 罒 衤 钅 龙"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "6" ]] ; then
  echo "竹 米 糸 糹 缶 网 羊 羽 老 而 耒 耳 聿 肉 臣 自 至 臼 舌 舛 舟 艮 色 艸 虍 虫 血 行 衣 襾 西 覀 赱 辵 页 齐"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "7" ]] ; then
  echo "見 角 言 訁 谷 豆 豕 豸 貝 赤 走 足 身 車 辛 辰 邑 酉 釆 里 長 鸟 鹵 麦 龟"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "8" ]] ; then
  echo "金 釒 門 阜 隶 隹 雨 靑 青 非 飠 鱼 黾 齿"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "9" ]] ; then
  echo "面 革 韋 韭 音 頁 风 飛 食 首 香"
fi

if [[ ${input[0]} == "radical" ]] && [[ ${input[1]} == "10+" ]] ; then
  echo "馬 骨 高 髟 鬥 鬯 鬲 鬼 魚 鳥 卤 鹿 麥 麻 黄 黃 黍 黑 黹 黽 鼎 鼓 鼔 鼠 鼻 齊 齒 龍 龜 龠"
fi

lookup
input=$result
insertspaces
oresult="${input[@]}"
oresult=($oresult)
mresult="${input[@]}"

for i in "${oresult[@]}" ; do
  input=$i
  lookup
  input=$result
  insertspaces
  array="${input[@]}"
  array=$(echo "${input[@]}" | sed "s/$i//g")
  array=($array)
  mresult="${mresult[@]}${array[@]}"
done

echo "${mresult[@]}"


