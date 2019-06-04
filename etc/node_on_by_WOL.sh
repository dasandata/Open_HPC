
# Node List
node[1]=aa:bb:cc:dd:ee:ff
node[2]=aa:bb:cc:dd:ee:ff
node[3]=aa:bb:cc:dd:ee:ff
node[4]=aa:bb:cc:dd:ee:ff
node[5]=aa:bb:cc:dd:ee:ff
node[6]=aa:bb:cc:dd:ee:ff
node[7]=aa:bb:cc:dd:ee:ff
node[8]=aa:bb:cc:dd:ee:ff


# Node Num + 1
NUM_NODES=9

# Wake On Command
for ((i=1 ; i<$NUM_NODES ; i++))
do
ether-wake -i em2 ${node[$i]}
done
