#!/bin/sh

macaddr=$1
firmware=$2

# パラメタ数が合わないときは中止
if [ $# != 2 ]; then
    echo ""
    echo "　$0 MACアドレス ファームウェアのファイル名"
    echo ""
    exit 1
fi

# ファームウェアが無ければ中止
if [ ! -f $firmware ]; then
    echo ""
    echo "　ファームウェア $firmware が見つかりません。中止します。"
    echo ""
    exit 1
fi

echo "以下の内容で実行します。"
echo "実行する場合は enter を、中止する場合は ctrl + c を押してください。"
echo "　MACアドレス $macaddr"
echo "　ファームウェア $firmware"
echo ""
echo "※"
echo "enter を押すと、arp 実行のためにログインアカウントのパスワード入力を要求します。"
read

echo "MACアドレスとIPアドレスの紐付けを解除します"
sudo arp -s 192.168.11.1 $macaddr

if [ $? -ne 0 ]; then
    echo "sudo arp の実行に失敗しました。処理を中止します。"
    echo ""
    exit 1
fi

echo "enter を押して３秒後に WHR-G301N の電源を入れてください。"
echo "画面にはカウントダウン表示が出ます。"
read


# ３秒カウントダウン
for i in $( seq 3 -1 1 ) ; do
    echo "$i\r"
    sleep 1
done

echo "電源を入れてください。"
sleep 1

# ７秒待つ
for i in $( seq 1 7 ) ; do
    echo "$i\r"
    sleep 1
done

echo ""
echo "tftpを実行します"
(
cat<<EOF
verbose
connect 192.168.11.1
binary
put $firmware
EOF
) | tftp

echo ""
echo "MACアドレスとIPアドレスの紐付けを解除します"
sudo arp -d 192.168.11.1

echo ""
echo "終了しました。ping 192.168.11.1 を実行し、復旧を待ちます。"

