"""
Implements hybrid heap/linked list data structure that enables log-lin time dynamic programming.
"""

from collections import deque
from copy import deepcopy
import numpy as np
import heapq


class Section(list):
    """
    Linked list node representing a section of the partition. Hijacks the standard list to enable ordering by the heapq module.
    """

    def __init__(self, adv, bound, label, prev, next):
        
        # this sets the hidden counter used by the heap
        self.append(adv)

        self.act = True
        self.adv = adv
        self.bound = bound
        self.label = label
        self.prev = prev
        self.next = next

    
    def __str__(self):

        return repr({"adv": self.adv, "bound": self.bound, "label": self.label})


class Partition(object):
    """
    Combines linked list and heap to allow for efficient extraction of the best classifier for some n.
    """

    def __init__(self, labels):

        self.heap = []
        self.classifiers = []
        self.start = self.end = None

        self._append(Section(1, 0, y[0], None, None))

        for i in range(1, len(y)):
            if y[i] == self.heap[-1].label:
                self.heap[-1].bound += 1
                self.heap[-1].adv += 1
                # this refreshs the hidden counter used by the heap
                self.heap[-1][0] += 1 
            else:
                self._append(Section(1, i, y[i], None, None))

        self.start.act = self.end.act = False
        # we drop the edge elements as we are not interested in poppin them
        self.heap = self.heap[1:-1]
        heapq.heapify(self.heap)


    def __str__(self):

        return str(self.flatten())

        
    def select(self, nint, verb = False, save = False):
        
        ninit = len(self.flatten())
        if ninit % 2 != nint % 2: self._remove_one()
        if save: self.classifiers.append(self.flatten())
        if verb: print(self.flatten())
        
        for i in range((ninit - nint) // 2):
            self._remove_two()
            if verb: print(self.flatten())
            if save: self.classifiers.append(self.flatten())
        
        return(save and self.classifiers or self.flatten())


    def flatten(self):
        
        sections = []
        cursor = self.start

        while cursor != None:
            sections.append({"adv": cursor.adv, "bound": cursor.bound, "label": cursor.label})
            cursor = cursor.next
        
        return(sections)


    def _append(self, section):
        
        if len(self.heap) == 0:
            self.start = section
        else:
            self.end.next = section
        
        section.prev = self.end
        self.end = section

        self.heap.append(section)
        
    
    def _remove_one(self):
    
        if self.start.adv > self.end.adv: self._rpop()
        else: self._lpop()
        

    def _remove_two(self):

        smallest = None
        while smallest is None:
            section = heapq.heappop(self.heap)
            smallest = (section.act and section or None)

        if smallest.adv > self.start.adv + self.end.adv:
            heapq.heappush(self.heap, smallest)
            self._lpop()
            self._rpop()
            
        else:
            smallest.act = smallest.prev.act = smallest.next.act = False

            replacement = Section(
                smallest.prev.adv + smallest.next.adv - smallest.adv,
                smallest.next.bound,
                smallest.next.label,
                smallest.prev.prev,
                smallest.next.next
            )

            if replacement.prev is None and replacement.next is None:
                self.start = self.end = replacement
                replacement.act = False
                
            elif replacement.prev is None:
                self.start = replacement
                self.start.act = False
                self.start.next.prev = self.start

            elif replacement.next is None:
                self.end = replacement
                self.end.act = False
                self.end.prev.next = self.end
            
            else:
                replacement.prev.next = replacement
                replacement.next.prev = replacement
                heapq.heappush(self.heap, replacement)

    
    def _lpop(self):
        
        self.start.next.act = False

        self.start = Section(
            self.start.next.adv - self.start.adv,
            self.start.next.bound,
            self.start.label,
            None,
            self.start.next.next
        )

        self.start.act = False
        self.start.next.prev = self.start


    def _rpop(self):
        
        self.end.prev.act = False

        self.end = Section(
            self.end.prev.adv - self.end.adv,
            self.end.bound,
            self.end.prev.label,
            self.end.prev.prev,
            None
        )

        self.end.act = False
        self.end.prev.next = self.end
