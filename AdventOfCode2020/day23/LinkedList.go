package main

import (
	"fmt"
)

type CustomLinkedList struct {
	head   *CustomListNode
	length int64
}

type CustomListNode struct {
	payload int64
	next    *CustomListNode
}

func (l *CustomLinkedList) prepend(n *CustomListNode) {
	second := l.head
	l.head = n
	l.head.next = second
	l.length++
}

func (l *CustomLinkedList) append(n *CustomListNode) {

	if l.head == nil {
		l.head = n
	} else {
		node := l.head
		for node.next != nil {
			node = node.next
		}
		node.next = n
	}
	l.length++
}

func (l *CustomLinkedList) appendNextTo(n *CustomListNode, pointer *CustomListNode) {
	node := l.head
	for node != nil {
		if node == pointer {
			next := node.next
			node.next = n
			n.next = next
			l.length++
			break
		}
		node = node.next
	}
}

func main() {

	linkedList := CustomLinkedList{}
	linkedList.append(&CustomListNode{payload: 10})

	node1 := &CustomListNode{payload: 1}
	node2 := &CustomListNode{payload: 2}
	node3 := &CustomListNode{payload: 3}

	linkedList.append(node1)
	linkedList.append(node2)
	linkedList.append(node3)

	linkedList.appendNextTo(&CustomListNode{payload: 69}, node2)

	node := linkedList.head
	for node != nil {
		fmt.Println(node.payload)
		node = node.next
	}

	fmt.Println("Length: ", linkedList.length)

}
